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
import 'package:frontend/dto/response/user_response_dto.dart';
import 'package:frontend/dto/response/member_response_dto.dart';
import 'package:frontend/components/profile_avatar.dart';
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
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            tabs: const [
              Tab(text: 'Friends'),
              Tab(text: 'Incoming'),
              Tab(text: 'Outgoing'),
            ],
          ),
        ),
        body: BlocConsumer<FriendshipBloc, FriendshipState>(
          listener: (context, state) {
            if (!context.mounted) return;
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
                  _FriendCardsList(
                    items: state.friends,
                    emptyText: 'No friends yet',
                    displayUserSelector: (ctx, item) => _otherUser(ctx, item),
                    trailingBuilder: (ctx, item) => IconButton(
                      icon: const Icon(Icons.person_remove),
                      onPressed: () => ctx.read<FriendshipBloc>().add(RemoveFriend(memberId: _otherUserId(ctx, item))),
                      tooltip: 'Remove friend',
                    ),
                  ),
                  _FriendCardsList(
                    items: state.incoming,
                    emptyText: 'No incoming requests',
                    displayUserSelector: (ctx, item) => item.requester,
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
                  _FriendCardsList(
                    items: state.outgoing,
                    emptyText: 'No outgoing requests',
                    displayUserSelector: (ctx, item) => item.addressee,
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

  static UserResponseDto _otherUser(BuildContext context, FriendshipWithUsersResponseDto f) {
    final profileState = context.read<UserProfileBloc>().state;
    if (profileState is UserProfileLoaded) {
      final meId = profileState.user.id;
      if (f.requester.id == meId) return f.addressee;
      if (f.addressee.id == meId) return f.requester;
    }
    return f.addressee; // default fall-back
  }
}

class _FriendCardsList extends StatelessWidget {
  const _FriendCardsList({
    required this.items,
    required this.emptyText,
    required this.trailingBuilder,
    required this.displayUserSelector,
  });

  final List<FriendshipWithUsersResponseDto> items;
  final String emptyText;
  final Widget Function(BuildContext, FriendshipWithUsersResponseDto) trailingBuilder;
  final UserResponseDto Function(BuildContext, FriendshipWithUsersResponseDto) displayUserSelector;

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
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final friendship = items[index];
          final user = displayUserSelector(context, friendship);
          return _FriendCard(
            user: user,
            trailing: trailingBuilder(context, friendship),
          );
        },
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({
    required this.user,
    required this.trailing,
  });

  final UserResponseDto user;
  final Widget trailing;

  String? _fullName(UserResponseDto u) {
    if (u is MemberResponseDto) {
      return '${u.firstName} ${u.lastName}'.trim();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _fullName(user);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileAvatar(
              base64Image: user.base64Image,
              size: 56,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.username,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fullName != null && fullName.isNotEmpty)
                    Text(
                      fullName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}
