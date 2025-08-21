import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../components/common/user_form_wrapper.dart';
import '../dto/request/user_request_dto.dart';
import '../styles/app_colors.dart';

class SignUpScreen extends HookWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void handleSubmit(UserRequestDto request) {
      context.read<AuthBloc>().add(RegisterRequested(userRequest: request));
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Registration successful!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return UserFormWrapper(
            title: 'Create your account',
            submitButtonText: 'Create account',
            onSubmit: handleSubmit,
            showAccountTypeSelector: true,
            isLoading: isLoading,
            bottomAction: TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Already have an account? Sign in'),
            ),
          );
        },
      ),
    );
  }
}

