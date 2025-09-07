import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/components/signup/signup_form_components.dart';

class AccountFormSection extends HookWidget {
  const AccountFormSection({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onObscureToggle,
    this.isEnabled = true,
  });

  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onObscureToggle;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Account',
      child: Column(
        children: [
          TextFormField(
            controller: usernameController,
            decoration: signupInputDecoration('Username', Icons.person),
            validator: (v) => SignupValidators.validateRequired(v, label: 'Username'),
            textInputAction: TextInputAction.next,
            enabled: isEnabled,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: emailController,
            decoration: signupInputDecoration('Email', Icons.email),
            validator: SignupValidators.validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: isEnabled,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passwordController,
            decoration: signupInputDecoration('Password', Icons.lock).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: isEnabled ? onObscureToggle : null,
              ),
            ),
            obscureText: obscurePassword,
            validator: (v) => SignupValidators.validateRequired(v, label: 'Password'),
            textInputAction: TextInputAction.done,
            enabled: isEnabled,
          ),
        ],
      ),
    );
  }
}
