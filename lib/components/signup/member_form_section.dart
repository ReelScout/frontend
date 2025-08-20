import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'signup_form_components.dart';

class MemberFormSection extends HookWidget {
  const MemberFormSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.birthDate,
    required this.onBirthDatePick,
    this.isEnabled = true,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final DateTime? birthDate;
  final VoidCallback onBirthDatePick;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Personal info',
      child: Column(
        children: [
          TextFormField(
            controller: firstNameController,
            decoration: signupInputDecoration('First name', Icons.badge),
            validator: (v) => SignupValidators.validateRequired(v, label: 'First name'),
            textInputAction: TextInputAction.next,
            enabled: isEnabled,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: lastNameController,
            decoration: signupInputDecoration('Last name', Icons.badge_outlined),
            validator: (v) => SignupValidators.validateRequired(v, label: 'Last name'),
            textInputAction: TextInputAction.next,
            enabled: isEnabled,
          ),
          const SizedBox(height: 12),
          BirthDatePicker(
            birthDate: birthDate,
            onPick: isEnabled ? onBirthDatePick : null,
          ),
        ],
      ),
    );
  }
}
