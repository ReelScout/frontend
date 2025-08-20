import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../model/owner.dart';
import '../../styles/app_colors.dart';

// Shared input decoration function
InputDecoration signupInputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    filled: true,
    fillColor: AppColors.inputBackground,
  );
}

// Shared validation functions
class SignupValidators {
  static String? validateRequired(String? v, {String label = 'This field'}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }
}

// Section card wrapper
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// Account type selector
enum AccountType { member, company }

class AccountTypeSelector extends StatelessWidget {
  const AccountTypeSelector({
    super.key,
    required this.accountType,
    required this.onChanged,
  });

  final AccountType accountType;
  final ValueChanged<AccountType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AccountType>(
      segments: const [
        ButtonSegment(value: AccountType.member, icon: Icon(Icons.person), label: Text('Member')),
        ButtonSegment(value: AccountType.company, icon: Icon(Icons.business), label: Text('Company')),
      ],
      selected: {accountType},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

// Image picker component
class ImagePickerRow extends StatelessWidget {
  const ImagePickerRow({
    super.key,
    required this.pickedPath,
    required this.onPick,
  });

  final String? pickedPath;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.inputBackground,
          backgroundImage: pickedPath != null ? FileImage(File(pickedPath!)) : null,
          child: pickedPath == null ? const Icon(Icons.person, color: Colors.grey) : null,
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.image),
          label: const Text('Upload profile image'),
        ),
      ],
    );
  }
}

// Birth date picker
class BirthDatePicker extends StatelessWidget {
  const BirthDatePicker({
    super.key,
    required this.birthDate,
    required this.onPick,
  });

  final DateTime? birthDate;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    final text = birthDate == null
        ? 'Select birth date'
        : '${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.inputBackground,
        ),
        child: Row(
          children: [
            const Icon(Icons.cake, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: birthDate == null ? Colors.grey.shade600 : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

// Owner row component
class OwnerRow extends HookWidget {
  const OwnerRow({
    super.key,
    required this.index,
    required this.owner,
    required this.onChanged,
    this.onRemove,
  });

  final int index;
  final Owner owner;
  final ValueChanged<Owner> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final firstNameCtrl = useTextEditingController(text: owner.firstName);
    final lastNameCtrl = useTextEditingController(text: owner.lastName);

    useEffect(() {
      void listener() {
        onChanged(Owner(
          firstName: firstNameCtrl.text,
          lastName: lastNameCtrl.text,
        ));
      }

      firstNameCtrl.addListener(listener);
      lastNameCtrl.addListener(listener);

      return () {
        firstNameCtrl.removeListener(listener);
        lastNameCtrl.removeListener(listener);
      };
    }, []);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Owner ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: firstNameCtrl,
                    decoration: signupInputDecoration('First name', Icons.person),
                    validator: (v) => SignupValidators.validateRequired(v, label: 'First name'),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: lastNameCtrl,
                    decoration: signupInputDecoration('Last name', Icons.person_outline),
                    validator: (v) => SignupValidators.validateRequired(v, label: 'Last name'),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
