import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/auth/auth_bloc.dart';
import 'package:frontend/bloc/auth/auth_event.dart';
import 'package:frontend/bloc/auth/auth_state.dart';
import 'package:frontend/bloc/user_profile/user_profile_bloc.dart';
import 'package:frontend/bloc/user_profile/user_profile_event.dart';
import 'package:frontend/bloc/user_profile/user_profile_state.dart';
import 'package:frontend/bloc/watchlist/watchlist_bloc.dart';
import 'package:frontend/bloc/watchlist/watchlist_event.dart';
import 'package:frontend/bloc/watchlist/watchlist_state.dart';
import 'package:frontend/components/password_change_helper.dart';
import 'package:frontend/components/profile_avatar.dart';
import 'package:frontend/dto/response/member_response_dto.dart';
import 'package:frontend/dto/response/production_company_response_dto.dart';
import 'package:frontend/dto/response/user_response_dto.dart';
import 'package:frontend/dto/response/watchlist_response_dto.dart';
import 'package:frontend/model/location.dart';
import 'package:frontend/pages/manage_contents_page.dart';
import 'package:frontend/pages/watchlist_detail_page.dart';
import 'package:frontend/pages/watchlists_page.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/profile_update_screen.dart';
import 'package:frontend/services/watchlist_service.dart';
import 'package:frontend/services/friendship_service.dart';
import 'package:frontend/bloc/friendship/friendship_bloc.dart';
import 'package:frontend/bloc/friendship/friendship_event.dart';
import 'package:frontend/bloc/friendship/friendship_state.dart';
import 'package:frontend/pages/friends_page.dart';
import 'package:frontend/components/promotion_request_dialog.dart';
import 'package:frontend/config/injection_container.dart';
import 'package:frontend/services/promotion_service.dart';
import 'package:frontend/dto/request/promotion_request_create_dto.dart';
import 'package:frontend/model/role.dart';
import 'package:frontend/pages/moderation/promotion_requests_page.dart';

class ProfilePage extends StatelessWidget {
  final UserResponseDto? viewingUser; // Optional user to view (if null, shows current user's profile)
  
  const ProfilePage({super.key, this.viewingUser});

  @override
  Widget build(BuildContext context) {
    // If viewing another user's profile, show it with the same layout but without action buttons
    if (viewingUser != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(viewingUser!.username),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    '',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 32),
                  _buildAuthenticatedProfile(context, user: viewingUser),
                  // Show public watchlists as a separate card if the user is a member
                  if (viewingUser is MemberResponseDto) ...[
                    const SizedBox(height: 24),
                    _buildPublicWatchlistsSection(context, viewingUser as MemberResponseDto),
                    const SizedBox(height: 24),
                    BlocProvider(
                      create: (_) => FriendshipBloc(
                        friendshipService: getIt<FriendshipService>(),
                      )..add(const LoadFriendshipData()),
                      child: BlocConsumer<FriendshipBloc, FriendshipState>(
                        listener: (context, state) {
                          if (state is FriendshipLoaded && state.lastMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.lastMessage!)),
                            );
                          }
                          if (state is FriendshipError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          }
                        },
                        builder: (ctx, state) {
                          final memberId = (viewingUser as MemberResponseDto).id;

                          Widget buildSendButton() => SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => ctx.read<FriendshipBloc>().add(SendFriendRequest(memberId: memberId)),
                                  icon: const Icon(Icons.person_add_alt),
                                  label: const Text('Send Friend Request'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.9),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              );

                          if (state is FriendshipLoading || state is FriendshipInitial) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (state is! FriendshipLoaded) {
                            return buildSendButton();
                          }

                          final friends = state.friends.any((f) => f.requester.id == memberId || f.addressee.id == memberId);
                          if (friends) {
                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: null,
                                    icon: const Icon(Icons.check),
                                    label: const Text('Friends'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => ctx.read<FriendshipBloc>().add(RemoveFriend(memberId: memberId)),
                                    icon: const Icon(Icons.person_remove),
                                    label: const Text('Remove'),
                                  ),
                                ),
                              ],
                            );
                          }

                          final incoming = state.incoming.any((f) => f.requester.id == memberId);
                          if (incoming) {
                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => ctx.read<FriendshipBloc>().add(AcceptFriendRequest(memberId: memberId)),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Accept'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => ctx.read<FriendshipBloc>().add(RejectFriendRequest(memberId: memberId)),
                                    icon: const Icon(Icons.close),
                                    label: const Text('Reject'),
                                  ),
                                ),
                              ],
                            );
                          }

                          final outgoing = state.outgoing.any((f) => f.addressee.id == memberId);
                          if (outgoing) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.hourglass_bottom),
                                label: const Text('Request Sent'),
                              ),
                            );
                          }

                          return buildSendButton();
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Original logic for current user's profile
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthSuccess) {
          context.read<UserProfileBloc>().add(LoadUserProfile());
        } else if (authState is AuthLoggedOut) {
          context.read<UserProfileBloc>().add(ClearUserProfile());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (state is AuthSuccess)
                      _buildAuthenticatedProfile(context)
                    else
                      _buildGuestProfile(context),
                    const SizedBox(height: 24),
                    if (state is! AuthSuccess) _buildFeaturesCard(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthenticatedProfile(BuildContext context, {UserResponseDto? user}) {
    // If a specific user is provided (viewing another user), use that user's data
    if (user != null) {
      return Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              ProfileAvatar(
                size: 80,
                base64Image: user.base64Image,
                fallbackColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                fallbackIconColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              
              Text(
                user.username,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.role.name.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildMoreProfileInfo(context, user),
              // No action buttons when viewing another user's profile
            ],
          ),
        ),
      );
    }
    
    // Original implementation for current user with action buttons
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, userProfileState) {
        return Card(
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                ProfileAvatar(
                  size: 80,
                  base64Image: userProfileState is UserProfileLoaded 
                      ? userProfileState.user.base64Image 
                      : null,
                  fallbackColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  fallbackIconColor: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                
                // Show user data based on profile state
                if (userProfileState is UserProfileLoaded) ...[
                  Text(
                    userProfileState.user.username,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProfileState.user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      userProfileState.user.role.name.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMoreProfileInfo(context, userProfileState.user),
                ] else if (userProfileState is UserProfileLoading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Loading profile...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ] else if (userProfileState is UserProfileError) ...[
                  Text(
                    'Profile Error',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userProfileState.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are successfully logged in',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                const SizedBox(height: 24),

                // Edit Profile Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute<bool>(
                          builder: (context) => const ProfileUpdateScreen(),
                        ),
                      );
                      // If profile was updated, refresh
                      if (result == true && context.mounted) {
                        context.read<UserProfileBloc>().add(LoadUserProfile());
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                
                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await PasswordChangeHelper.showPasswordChangeDialog(context);
                    },
                    icon: const Icon(Icons.key),
                    label: const Text('Change Password'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // My Watchlists Button
                if (userProfileState is UserProfileLoaded && userProfileState.user is MemberResponseDto) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to watchlists page
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => BlocProvider(
                              create: (context) => WatchlistBloc(
                                watchlistService: getIt<WatchlistService>(),
                              ),
                              child: const WatchlistsPage(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.playlist_play),
                      label: const Text('My Watchlists'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.9),
                        foregroundColor: Colors.white,
                      ),
                  ),
                ),
                const SizedBox(height: 12),

                // Request Verification (only for MEMBER role)
                if (userProfileState is UserProfileLoaded &&
                    userProfileState.user.role == Role.member) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final message = await showDialog<String?>(
                          context: context,
                          builder: (_) => const PromotionRequestDialog(),
                        );
                        if (!context.mounted || message == null) return;

                        try {
                          final service = getIt<PromotionService>();
                          await service.requestVerifiedPromotion(
                            PromotionRequestCreateDto(message: message.isEmpty ? null : message),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Richiesta di verifica inviata')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Invio richiesta fallito: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.verified_user_outlined),
                      label: const Text('Richiedi verifica'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Request Promotion (only for VERIFIED_MEMBER role)
                if (userProfileState is UserProfileLoaded &&
                    userProfileState.user.role == Role.verifiedMember) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final message = await showDialog<String?>(
                          context: context,
                          builder: (_) => const PromotionRequestDialog(),
                        );
                        if (!context.mounted || message == null) return;

                        try {
                          final service = getIt<PromotionService>();
                          await service.requestModeratorPromotion(
                            PromotionRequestCreateDto(message: message.isEmpty ? null : message),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Promotion request submitted')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to submit request: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.campaign_outlined),
                      label: const Text('Request promotion'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Moderation tools (for MODERATOR and ADMIN)
                if (userProfileState is UserProfileLoaded &&
                    (userProfileState.user.role == Role.moderator || userProfileState.user.role == Role.admin)) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PromotionRequestsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.manage_accounts),
                      label: const Text('Role upgrade requests'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                  // Friends Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const FriendsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.group),
                      label: const Text('Friends'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.9),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Manage Contents Button (only for production companies)
                if (userProfileState is UserProfileLoaded && userProfileState.user is ProductionCompanyResponseDto) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to manage contents page
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const ManageContentsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.movie_creation),
                      label: const Text('Manage Contents'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoreProfileInfo(BuildContext context, UserResponseDto user) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    List<Widget> children;
    if (user is MemberResponseDto) {
      final birth = user.birthDate.toLocal();
      final birthDateStr = '${birth.year.toString().padLeft(4, '0')}-${birth.month.toString().padLeft(2, '0')}-${birth.day.toString().padLeft(2, '0')}';
      children = [
        _infoTile(context, Icons.badge, 'First name', user.firstName),
        _infoTile(context, Icons.badge_outlined, 'Last name', user.lastName),
        _infoTile(context, Icons.cake, 'Birth date', birthDateStr),
        _buildPreferredGenresSection(context, user.favoriteGenres),
      ];
    } else if (user is ProductionCompanyResponseDto) {
      final loc = user.location;
      final locationStr = _formatLocation(loc);
      final ownersChips = user.owners.isEmpty
          ? Text('No owners listed', style: theme.textTheme.bodyMedium)
          : Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final o in user.owners) Chip(label: Text('${o.firstName} ${o.lastName}')),
              ],
            );
      children = [
        _infoTile(context, Icons.business, 'Company name', user.name),
        _infoTile(context, Icons.language, 'Website', user.website),
        _infoTile(context, Icons.location_on, 'Location', locationStr),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.people, color: primary),
          title: Text('Owners', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
          subtitle: ownersChips,
        ),
      ];
    } else {
      children = [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('No additional information available', style: theme.textTheme.bodyMedium),
        ),
      ];
    }

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(top: 8),
      initiallyExpanded: false,
      maintainState: true,
      leading: Icon(Icons.info_outline, color: primary),
      title: Text('More profile info', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      children: children,
    );
  }

  String _formatLocation(Location l) {
    final parts = <String>[];
    if (l.address.trim().isNotEmpty) parts.add(l.address.trim());
    if (l.city.trim().isNotEmpty) parts.add(l.city.trim());
    if (l.state.trim().isNotEmpty) parts.add(l.state.trim());
    if (l.country.trim().isNotEmpty) parts.add(l.country.trim());
    if (l.postalCode.trim().isNotEmpty) parts.add(l.postalCode.trim());
    return parts.join(', ');
  }

  Widget _infoTile(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
      subtitle: Text(value, style: theme.textTheme.bodyMedium),
    );
  }

  Widget _buildPreferredGenresSection(BuildContext context, List<String>? favoriteGenres) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    
    Widget genresContent;
    if (favoriteGenres == null || favoriteGenres.isEmpty) {
      genresContent = Text(
        'No preferred genres',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.grey[600],
        ),
      );
    } else {
      genresContent = Wrap(
        spacing: 8,
        runSpacing: 4,
        children: favoriteGenres.map((genre) => Chip(
          label: Text(genre),
          backgroundColor: primary.withValues(alpha: 0.1),
          labelStyle: TextStyle(
            color: primary,
            fontSize: 12,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        )).toList(),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.movie_filter, color: primary),
      title: Text(
        'Preferred Genres',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: genresContent,
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Guest User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to unlock personalized features',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Features you\'ll unlock:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const FeatureItem(
              icon: Icons.favorite,
              title: 'Save Favorites',
              description: 'Keep track of movies and shows you love',
            ),
            const SizedBox(height: 12),
            const FeatureItem(
              icon: Icons.recommend,
              title: 'Personalized Recommendations',
              description: 'Get suggestions based on your preferences',
            ),
            const SizedBox(height: 12),
            const FeatureItem(
              icon: Icons.history,
              title: 'Watch History',
              description: 'Track what you\'ve watched and rated',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicWatchlistsSection(BuildContext context, MemberResponseDto member) {
    return BlocProvider(
      create: (context) => WatchlistBloc(
        watchlistService: getIt<WatchlistService>(),
      )..add(LoadPublicWatchlistsByMemberId(memberId: member.id)),
      child: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          return Card(
            elevation: 4,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.playlist_play,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Public Watchlists',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPublicWatchlistsContent(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPublicWatchlistsContent(BuildContext context, WatchlistState state) {
    if (state is WatchlistLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is WatchlistLoaded) {
      final publicWatchlists = state.publicWatchlists ?? [];
      
      if (publicWatchlists.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.playlist_remove,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'No public watchlists',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: publicWatchlists.map((watchlist) => _buildWatchlistTile(context, watchlist)).toList(),
      );
    }

    if (state is WatchlistError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load watchlists',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildWatchlistTile(BuildContext context, WatchlistResponseDto watchlist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => WatchlistDetailPage(
                watchlistId: watchlist.id,
                watchlistName: watchlist.name,
              ),
            ),
          );
        },
        leading: Icon(
          Icons.playlist_play,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          watchlist.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          watchlist.isPublic ? 'Public' : 'Private',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[600],
          size: 16,
        ),
      ),
    );
  }

}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
