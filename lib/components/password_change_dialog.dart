import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:dio/dio.dart';
import 'package:frontend/dto/response/custom_response_dto.dart';
import '../dto/request/user_password_change_request_dto.dart';
import '../services/user_service.dart';
import '../styles/app_colors.dart';
import '../config/injection_container.dart';

class PasswordChangeDialog extends HookWidget {
  const PasswordChangeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    
    final isCurrentPasswordVisible = useState(false);
    final isNewPasswordVisible = useState(false);
    final isConfirmPasswordVisible = useState(false);
    final isLoading = useState(false);

    String? validateCurrentPassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'Current password is required';
      }
      return null;
    }

    String? validateNewPassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'New password is required';
      }
      if (value.length < 8) {
        return 'New password must be at least 8 characters';
      }
      if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
        return 'Password must contain uppercase, lowercase, and number';
      }
      return null;
    }

    String? validateConfirmPassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != newPasswordController.text) {
        return 'Passwords do not match';
      }
      return null;
    }

    Future<void> handlePasswordChange() async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      isLoading.value = true;

      try {
        final userService = getIt<UserService>();
        final requestDto = UserPasswordChangeRequestDto(
          currentPassword: currentPasswordController.text,
          newPassword: newPasswordController.text,
          confirmPassword: confirmPasswordController.text,
        );

        CustomResponseDto response = await userService.changePassword(requestDto);

        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        final String error = e is DioException ? CustomResponseDto.fromJson(e.response?.data).message : 'An unexpected error occurred';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        isLoading.value = false;
      }
    }
    return AlertDialog(
      title: Text(
        'Change Password',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current Password Field
              TextFormField(
                controller: currentPasswordController,
                obscureText: !isCurrentPasswordVisible.value,
                validator: validateCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Enter your current password',
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.inputFocused, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isCurrentPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // New Password Field
              TextFormField(
                controller: newPasswordController,
                obscureText: !isNewPasswordVisible.value,
                validator: validateNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter your new password',
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.inputFocused, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isNewPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      isNewPasswordVisible.value = !isNewPasswordVisible.value;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: confirmPasswordController,
                obscureText: !isConfirmPasswordVisible.value,
                validator: validateConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  hintText: 'Confirm your new password',
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.inputFocused, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Password requirements info
              Text(
                'Password must be at least 8 characters and contain uppercase, lowercase, and numbers',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isLoading.value ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
        ),

        // Change Password Button
        ElevatedButton(
          onPressed: isLoading.value ? null : handlePasswordChange,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                  ),
                )
              : const Text('Change Password'),
        ),
      ],
    );
  }
}