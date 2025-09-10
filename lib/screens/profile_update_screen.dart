import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:frontend/bloc/user_profile/user_profile_bloc.dart';
import 'package:frontend/bloc/user_profile/user_profile_event.dart';
import 'package:frontend/bloc/user_profile/user_profile_state.dart';
import 'package:frontend/components/common/user_form_wrapper.dart';
import 'package:frontend/dto/request/user_request_dto.dart';
import 'package:frontend/dto/response/user_response_dto.dart';
import 'package:frontend/styles/app_colors.dart';

class ProfileUpdateScreen extends HookWidget {
  const ProfileUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cachedUser = useState<UserResponseDto?>(null);
    
    // Listen to bloc state changes and update cached user outside of build
    useEffect(() {
      final bloc = context.read<UserProfileBloc>();
      final subscription = bloc.stream.listen((state) {
        if (state is UserProfileLoaded) {
          cachedUser.value = state.user;
        }
      });
      
      // Also check current state in case it's already loaded
      final currentState = bloc.state;
      if (currentState is UserProfileLoaded) {
        cachedUser.value = currentState.user;
      }
      
      return subscription.cancel;
    }, []);
    
    void handleSubmit(UserRequestDto request) {
      context.read<UserProfileBloc>().add(UpdateUserProfile(userRequest: request));
    }

    return BlocListener<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (!context.mounted) return;
        if (state is UserProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Profile updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is UserProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is! UserProfileLoaded && state is! UserProfileUpdating && state is! UserProfileError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Edit profile'),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          // Use cached user data which persists across state transitions
          final user = cachedUser.value;

          if (user == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Edit profile'),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final isLoading = state is UserProfileUpdating;

          return UserFormWrapper(
            title: 'Edit profile',
            submitButtonText: 'Save changes',
            onSubmit: handleSubmit,
            existingUser: user,
            isLoading: isLoading,
            bottomAction: TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          );
        },
      ),
    );
  }
}
