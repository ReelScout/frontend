import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/bloc/friendship/friendship_bloc.dart';
import 'package:frontend/bloc/friendship/friendship_event.dart';
import 'package:frontend/bloc/friendship/friendship_state.dart';
import 'package:frontend/bloc/user_profile/user_profile_bloc.dart';
import 'package:frontend/bloc/user_profile/user_profile_state.dart';
import 'package:frontend/config/injection_container.dart';
import 'package:frontend/dto/response/friendship_with_users_response_dto.dart';
import 'package:frontend/services/friendship_service.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FriendshipBloc(friendshipService: getIt<FriendshipService>())..add(const LoadFriendshipData()),
      child: const _FriendsView(),
    );
  }
}

class _FriendsView extends HookWidget {
  const _FriendsView();

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 3);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          bottom: TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: 'Friends'),
              Tab(text: 'Incoming'),
              Tab(text: 'Outgoing'),
            ],
          ),
        ),
        body: BlocConsumer<FriendshipBloc, FriendshipState>(
          listener: (context, state) {
            if (state is FriendshipLoaded && state.lastMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.lastMessage!)),
              );
            }
          },
          builder: (context, state) {
            if (state is FriendshipLoading || state is FriendshipInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FriendshipError) {
              return Center(child: Text(state.message));
            }
            if (state is FriendshipLoaded) {
              return TabBarView(
                controller: tabController,
                children: [
                  _FriendList(
                    items: state.friends,
                    emptyText: 'No friends yet',
                    trailingBuilder: (ctx, item) => IconButton(
                      icon: const Icon(Icons.person_remove),
                      onPressed: () => ctx.read<FriendshipBloc>().add(RemoveFriend(memberId: _otherUserId(ctx, item))),
                      tooltip: 'Remove friend',
                    ),
                  ),
                  _FriendList(
                    items: state.incoming,
                    emptyText: 'No incoming requests',
                    trailingBuilder: (ctx, item) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => ctx.read<FriendshipBloc>().add(AcceptFriendRequest(memberId: item.requester.id)),
                          tooltip: 'Accept',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => ctx.read<FriendshipBloc>().add(RejectFriendRequest(memberId: item.requester.id)),
                          tooltip: 'Reject',
                        ),
                      ],
                    ),
                  ),
                  _FriendList(
                    items: state.outgoing,
                    emptyText: 'No outgoing requests',
                    trailingBuilder: (ctx, item) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Pending'),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
    );
  }

  static int _otherUserId(BuildContext context, FriendshipWithUsersResponseDto f) {
    final profileState = context.read<UserProfileBloc>().state;
    if (profileState is UserProfileLoaded) {
      final meId = profileState.user.id;
      if (f.requester.id == meId) return f.addressee.id;
      if (f.addressee.id == meId) return f.requester.id;
    }
    // We don't know current user id here; removing a friend requires the other member id.
    // For accepted friendships, either requester or addressee is the other person; the backend handles both.
    // We choose addressee by default for consistency; if the current user is addressee, removing by requester id also works.
    // The backend endpoint "remove/{memberId}" matches the other member id.
    // Prefer returning the non-equal id is not possible, so return addressee.id.
    return f.addressee.id;
  }
}

class _FriendList extends StatelessWidget {
  const _FriendList({
    required this.items,
    required this.emptyText,
    required this.trailingBuilder,
  });

  final List<FriendshipWithUsersResponseDto> items;
  final String emptyText;
  final Widget Function(BuildContext, FriendshipWithUsersResponseDto) trailingBuilder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(emptyText));
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FriendshipBloc>().add(const RefreshFriendshipData());
      },
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          final title = item.requester.username;
          final subtitle = '↔ ${item.addressee.username}';
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: trailingBuilder(context, item),
          );
        },
      ),
    );
  }
}
