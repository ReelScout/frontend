import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/user_profile/user_profile_state.dart';
import 'package:frontend/bloc/user_profile/user_profile_bloc.dart';
import 'package:frontend/config/injection_container.dart';
import 'package:frontend/dto/response/chat_message_response_dto.dart';
import 'package:frontend/services/chat_realtime_service.dart';
import 'package:frontend/services/chat_service.dart';

class DmChatPage extends StatefulWidget {
  const DmChatPage({super.key, required this.peerUsername});

  final String peerUsername;

  @override
  State<DmChatPage> createState() => _DmChatPageState();
}

class _DmChatPageState extends State<DmChatPage> {
  final _messages = <ChatMessageResponseDto>[];
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  StreamSubscription<ChatMessageResponseDto>? _dmSub;
  bool _connecting = true;
  bool _atBottom = true;
  int _newSinceScroll = 0;

  late final ChatRealtimeService _realtime = getIt<ChatRealtimeService>();
  late final ChatService _chatService = getIt<ChatService>();

  String? _myUsername;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<UserProfileBloc>().state;
    if (profileState is UserProfileLoaded) {
      _myUsername = profileState.user.username;
    }
    _scrollController.addListener(_onScroll);
    _init();
  }

  Future<void> _init() async {
    try {
      // Load recent DM history with peer
      final page = await _chatService.getDirectHistory(widget.peerUsername, 0, 50);
      setState(() {
        _messages
          ..clear()
          ..addAll(page.content); // backend returns ascending; keep ascending so new go to bottom
      });

      await _realtime.connect(onConnected: () {
        setState(() => _connecting = false);
        _dmSub = _realtime.subscribeDirect().listen((event) {
          // Only messages in this conversation: sent by peer or sent to peer
          if (event.sender == widget.peerUsername || event.recipient == widget.peerUsername) {
            final isMine = event.sender == _myUsername;
            setState(() {
              _messages.add(event);
              if (!_atBottom && !isMine) {
                _newSinceScroll += 1;
              }
            });
            if (_atBottom || isMine) {
              _scrollToBottom();
            }
          }
        });
      }, onError: (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chat connection error: $err')),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load chat: $e')),
        );
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final isNearBottom = pos.pixels >= (pos.maxScrollExtent - 24);
    if (isNearBottom && !_atBottom) {
      setState(() {
        _atBottom = true;
        _newSinceScroll = 0;
      });
    } else if (!isNearBottom && _atBottom) {
      setState(() {
        _atBottom = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _dmSub?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _realtime.sendDirect(widget.peerUsername, text);
    _textController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final hasMarker = _newSinceScroll > 0;
    final markerIndex = hasMarker ? (_messages.length - _newSinceScroll) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerUsername),
      ),
      body: Column(
        children: [
          if (_connecting)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length + (hasMarker ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (hasMarker && index == markerIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const Expanded(child: Divider(thickness: 1)),
                            const SizedBox(width: 8),
                            Text('New messages', style: Theme.of(context).textTheme.labelMedium),
                            const SizedBox(width: 8),
                            const Expanded(child: Divider(thickness: 1)),
                          ],
                        ),
                      );
                    }

                    final msgIndex = (hasMarker && index > (markerIndex ?? 0)) ? index - 1 : index;
                    final m = _messages[msgIndex];
                    final isMine = m.sender == _myUsername;
                    return Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMine ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMine)
                              Text(
                                m.sender,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            Text(m.content),
                            const SizedBox(height: 4),
                            Text(
                              TimeOfDay.fromDateTime(m.timestamp.toLocal()).format(context),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (_newSinceScroll > 0)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          _scrollToBottom();
                          setState(() {
                            _newSinceScroll = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '$_newSinceScroll new message${_newSinceScroll == 1 ? '' : 's'} — tap to view',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
