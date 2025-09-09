import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/config/injection_container.dart';
import 'package:frontend/dto/response/chat_message_response_dto.dart';
import 'package:frontend/services/chat_realtime_service.dart';
import 'package:frontend/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.roomId, this.title});

  final String roomId; // e.g., room:general, or any room key used by backend
  final String? title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messages = <ChatMessageResponseDto>[];
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  StreamSubscription<ChatMessageResponseDto>? _roomSub;
  bool _connecting = true;

  late final ChatRealtimeService _realtime = getIt<ChatRealtimeService>();
  late final ChatService _chatService = getIt<ChatService>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // Load recent history (last page 0, size 50)
      final page = await _chatService.getRoomHistory(widget.roomId, 0, 50);
      setState(() {
        _messages
          ..clear()
          ..addAll(page.content.reversed); // show oldest at top, append new at end
      });

      await _realtime.connect(onConnected: () {
        setState(() => _connecting = false);
        _roomSub = _realtime.subscribeRoom(widget.roomId).listen((event) {
          setState(() {
            _messages.add(event);
          });
          _scrollToBottom();
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
    _roomSub?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _realtime.sendToRoom(widget.roomId, text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Chat: ${widget.roomId}'),
      ),
      body: Column(
        children: [
          if (_connecting)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return ListTile(
                  title: Text(m.sender),
                  subtitle: Text(m.content),
                  trailing: Text(
                    TimeOfDay.fromDateTime(m.timestamp.toLocal()).format(context),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
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

