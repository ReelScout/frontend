import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../bloc/user_profile/user_profile_bloc.dart';
import '../bloc/user_profile/user_profile_state.dart';
import '../components/common/user_form_wrapper.dart';
import '../config/injection_container.dart';
import '../dto/request/user_request_dto.dart';
import '../services/user_service.dart';
import '../services/token_service.dart';  // Add this import
import '../styles/app_colors.dart';

class ProfileUpdateScreen extends HookWidget {
  const ProfileUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is! UserProfileLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit profile'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return HookBuilder(
          builder: (context) {
            final user = state.user;

            Future<void> handleSubmit(UserRequestDto request) async {
              try {
                final userService = getIt<UserService>();
                final tokenService = getIt<TokenService>();

                // Check if username is being changed
                final isUsernameChanged = user.username != request.username;

                // Call update endpoint (now returns UserLoginResponseDto)
                final response = await userService.update(request);

                // If username changed and backend returned new token, update stored token
                if (isUsernameChanged && response!.accessToken.isNotEmpty) {
                  await tokenService.saveToken(response.accessToken);
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.of(context).pop(true);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Update failed: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            }

            return UserFormWrapper(
              title: 'Edit profile',
              submitButtonText: 'Save changes',
              onSubmit: handleSubmit,
              existingUser: user,
              bottomAction: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            );
          },
        );
      },
    );
  }
}