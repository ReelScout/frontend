import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/config/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/user_profile/user_profile_bloc.dart';
import 'package:frontend/bloc/user_profile/user_profile_state.dart';
import 'package:frontend/bloc/navigation/navigation_bloc.dart';
import 'package:frontend/bloc/navigation/navigation_state.dart';
import 'package:frontend/dto/response/friendship_with_users_response_dto.dart';
import 'package:frontend/dto/response/member_response_dto.dart';
import 'package:frontend/dto/response/user_response_dto.dart';
import 'package:frontend/dto/response/conversation_response_dto.dart';
import 'package:frontend/pages/dm_chat_page.dart';
import 'package:frontend/services/friendship_service.dart';
import 'package:frontend/services/chat_service.dart';
import 'package:frontend/config/chat_event_bus.dart';
import 'package:frontend/dto/response/chat_message_response_dto.dart';
import 'package:frontend/config/unread_badge.dart';

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({super.key});

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  final _friendsService = getIt<FriendshipService>();
  final _chatService = getIt<ChatService>();
  List<FriendshipWithUsersResponseDto> _friends = [];
  List<ConversationResponseDto> _conversations = [];
  bool _loading = true;
  String? _error;
  StreamSubscription<ChatMessageResponseDto>? _dmSub;
  String? _myUsername;
  final Map<String, int> _unreadByUser = <String, int>{};
  String? _activePeer;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<UserProfileBloc>().state;
    if (profileState is UserProfileLoaded) {
      _myUsername = profileState.user.username;
    }
    _load();
    _initRealtime();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final friends = await _friendsService.getFriends();
      final conv = await _chatService.getRecentConversations(50);
      conv.sort((a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
      setState(() {
        _friends = friends;
        _conversations = conv;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load chats';
        _loading = false;
      });
    }
  }

  Future<void> _initRealtime() async {
    // Subscribe to global chat event bus (already attached on login)
    _dmSub = chatEventBus.onMessage.listen(_onRealtimeMessage);
  }

  void _onRealtimeMessage(ChatMessageResponseDto e) {
    // Ignore malformed events (DMs should always include recipient)
    if (e.recipient == null) return;
    final me = _myUsername;
    // Fallback: infer counterpart if my username isn't loaded yet
    String counterpart;
    if (me == null) {
      // Prefer matching an existing conversation by usernames
      final hasSender = _conversations.any((c) => c.counterpartUsername == e.sender);
      final hasRecipient = _conversations.any((c) => c.counterpartUsername == e.recipient);
      if (hasSender && !hasRecipient) {
        counterpart = e.sender;
      } else if (!hasSender && hasRecipient && e.recipient != null) {
        counterpart = e.recipient!;
      } else {
        // default assume incoming
        counterpart = e.sender;
      }
    } else {
      counterpart = e.sender == me ? (e.recipient ?? e.sender) : e.sender;
    }

    setState(() {
      final idx = _conversations.indexWhere((c) => c.counterpartUsername == counterpart);
      final updated = ConversationResponseDto(
        counterpartUsername: counterpart,
        lastMessageSender: e.sender,
        lastMessageContent: e.content,
        lastMessageTimestamp: e.timestamp,
      );
      if (idx >= 0) {
        _conversations.removeAt(idx);
      }
      _conversations.insert(0, updated);
      // Unread: only increment on incoming messages and when not viewing that chat
      final isIncoming = me == null ? (e.sender != counterpart) : (e.sender != me);
      if (_activePeer == counterpart) {
        _unreadByUser[counterpart] = 0;
      } else if (isIncoming) {
        _unreadByUser[counterpart] = (_unreadByUser[counterpart] ?? 0) + 1;
      }
      if (_conversations.length > 200) {
        _conversations = _conversations.sublist(0, 200);
      }
      _updateGlobalUnread();
    });
  }

  @override
  void dispose() {
    _dmSub?.cancel();
    super.dispose();
  }

  UserResponseDto _friendUser(FriendshipWithUsersResponseDto f, int? myId) {
    if (myId == null) return f.addressee;
    return f.requester.id == myId ? f.addressee : f.requester;
  }

  String? _fullName(UserResponseDto u) {
    if (u is MemberResponseDto) {
      final fn = '${u.firstName} ${u.lastName}'.trim();
      return fn.isEmpty ? null : fn;
    }
    return null;
  }

  void _openNewChatPicker() async {
    if (_friends.isEmpty) return;
    final selected = await showModalBottomSheet<UserResponseDto>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Start New Chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Builder(builder: (ctx2) {
                    final profileState = ctx2.read<UserProfileBloc>().state;
                    final myId = profileState is UserProfileLoaded ? profileState.user.id : null;
                    return ListView.builder(
                      itemCount: _friends.length,
                      itemBuilder: (ctx, i) {
                        final friend = _friends[i];
                        final user = _friendUser(friend, myId);
                        return ListTile(
                          title: Text(user.username),
                          subtitle: _fullName(user) != null ? Text(_fullName(user)!) : null,
                          onTap: () => Navigator.of(ctx).pop(user),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() {
        _activePeer = selected.username;
        _unreadByUser[_activePeer!] = 0;
      });
      _updateGlobalUnread();
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => DmChatPage(peerUsername: selected.username),
      ));
      if (!mounted) return;
      setState(() {
        if (_activePeer == selected.username) {
          _activePeer = null;
          _unreadByUser[selected.username] = 0;
        }
        _updateGlobalUnread();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (prev, curr) => prev.selectedIndex != curr.selectedIndex,
      listener: (context, nav) {
        // Chat tab index is 2
        if (nav.selectedIndex == 2) {
          _load();
        }
      },
      child: BlocListener<UserProfileBloc, UserProfileState>(
        listenWhen: (prev, curr) => curr is UserProfileLoaded,
        listener: (context, state) {
          if (state is UserProfileLoaded) {
            _myUsername = state.user.username;
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('My Chats')),
          body: RefreshIndicator(
            onRefresh: _load,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? ListView(children: [Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))])
                    : _conversations.isEmpty
                        ? ListView(children: const [Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No conversations yet')))])
                        : ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: _conversations.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final c = _conversations[index];
                              final preview = '${c.lastMessageSender}: ${c.lastMessageContent}';
                              final unread = _unreadByUser[c.counterpartUsername] ?? 0;
                              final timeText = TimeOfDay.fromDateTime(c.lastMessageTimestamp.toLocal()).format(context);
                               return ListTile(
                                 leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text(c.counterpartUsername),
                                subtitle: Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(timeText, style: Theme.of(context).textTheme.bodySmall),
                                    if (unread > 0)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          unread.toString(),
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                 onTap: () async {
                                   setState(() {
                                     _activePeer = c.counterpartUsername;
                                     _unreadByUser[_activePeer!] = 0;
                                   });
                                   _updateGlobalUnread();
                                   await Navigator.of(context).push(
                                     MaterialPageRoute<void>(
                                       builder: (_) => DmChatPage(peerUsername: c.counterpartUsername),
                                     ),
                                   );
                                   if (!mounted) return;
                                   setState(() {
                                     if (_activePeer == c.counterpartUsername) {
                                       _activePeer = null;
                                       _unreadByUser[c.counterpartUsername] = 0;
                                     }
                                     _updateGlobalUnread();
                                   });
                                 },
                               );
                             },
                           ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openNewChatPicker,
            child: const Icon(Icons.chat),
          ),
        ),
      ),
    );
  }

  void _updateGlobalUnread() {
    final anyUnread = _unreadByUser.values.any((v) => v > 0);
    unreadBadge.setUnread(anyUnread);
  }
}
