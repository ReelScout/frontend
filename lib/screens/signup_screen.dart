import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

import '../dto/request/member_request_dto.dart';
import '../dto/request/production_company_request_dto.dart';
import '../dto/request/user_request_dto.dart';
import '../model/location.dart';
import '../model/owner.dart';
import '../styles/app_colors.dart';

enum AccountType { member, company }

class SignUpScreen extends HookWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Common fields
    final accountType = useState(AccountType.member);
    final usernameCtrl = useTextEditingController();
    final emailCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final obscurePassword = useState(true);
    final base64Image = useState<String?>(null);
    final pickedImagePath = useState<String?>(null);

    // Member fields
    final firstNameCtrl = useTextEditingController();
    final lastNameCtrl = useTextEditingController();
    final birthDate = useState<DateTime?>(null);

    // Company fields
    final companyNameCtrl = useTextEditingController();
    final websiteCtrl = useTextEditingController();
    final addressCtrl = useTextEditingController();
    final cityCtrl = useTextEditingController();
    final stateCtrl = useTextEditingController();
    final countryCtrl = useTextEditingController();
    final postalCtrl = useTextEditingController();
    final owners = useState<List<Owner>>([
      Owner(firstName: '', lastName: ''),
    ]);

    Future<void> pickImage() async {
      try {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 75,
        );
        if (image != null) {
          final bytes = await File(image.path).readAsBytes();
          base64Image.value = base64Encode(bytes);
          pickedImagePath.value = image.path;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image pick failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }

    void addOwner() {
      owners.value = [...owners.value, Owner(firstName: '', lastName: '')];
    }

    void removeOwner(int index) {
      final list = [...owners.value];
      if (list.length > 1) {
        list.removeAt(index);
        owners.value = list;
      }
    }

    void updateOwner(int index, {String? firstName, String? lastName}) {
      final list = [...owners.value];
      final current = list[index];
      list[index] = Owner(
        firstName: firstName ?? current.firstName,
        lastName: lastName ?? current.lastName,
      );
      owners.value = list;
    }

    Future<void> chooseBirthDate() async {
      final now = DateTime.now();
      final initial = birthDate.value ?? DateTime(now.year - 18, now.month, now.day);
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1900),
        lastDate: now,
      );
      if (picked != null) {
        birthDate.value = picked;
      }
    }

    void submit() {
      if (!formKey.currentState!.validate()) return;

      final type = accountType.value;
      final String username = usernameCtrl.text.trim();
      final String email = emailCtrl.text.trim();
      final String password = passwordCtrl.text;

      UserRequestDto request;

      if (type == AccountType.member) {
        if (birthDate.value == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a birth date')),
          );
          return;
        }

        request = MemberRequestDto(
          username: username,
          email: email,
          password: password,
          base64Image: base64Image.value,
          firstName: firstNameCtrl.text.trim(),
          lastName: lastNameCtrl.text.trim(),
          birthDate: birthDate.value!,
        );
      } else {
        // Validate owners
        final validOwners = owners.value
            .where((o) => o.firstName.trim().isNotEmpty || o.lastName.trim().isNotEmpty)
            .toList();

        if (validOwners.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add at least one owner')),
          );
          return;
        }

        final loc = Location(
          address: addressCtrl.text.trim(),
          city: cityCtrl.text.trim(),
          state: stateCtrl.text.trim(),
          country: countryCtrl.text.trim(),
          postalCode: postalCtrl.text.trim(),
        );

        request = ProductionCompanyRequestDto(
          username: username,
          email: email,
          password: password,
          base64Image: base64Image.value,
          name: companyNameCtrl.text.trim(),
          location: loc,
          website: websiteCtrl.text.trim(),
          owners: validOwners,
        );
      }

      context.read<AuthBloc>().add(RegisterRequested(userRequest: request));
    }

    String? validateRequired(String? v, {String label = 'This field'}) {
      if (v == null || v.trim().isEmpty) return '$label is required';
      return null;
    }

    String? validateEmail(String? v) {
      if (v == null || v.trim().isEmpty) return 'Email is required';
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
      return null;
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

          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: const Text('Create your account'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _AccountTypeSelector(accountType: accountType),
                      const SizedBox(height: 16),
                      _ImagePickerRow(
                        pickedPath: pickedImagePath.value,
                        onPick: isLoading ? null : pickImage,
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Account',
                        child: Column(
                          children: [
                            TextFormField(
                              controller: usernameCtrl,
                              decoration: _inputDecoration('Username', Icons.person),
                              validator: (v) => validateRequired(v, label: 'Username'),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailCtrl,
                              decoration: _inputDecoration('Email', Icons.email),
                              validator: validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            HookBuilder(builder: (context) {
                              return TextFormField(
                                controller: passwordCtrl,
                                decoration: _inputDecoration('Password', Icons.lock).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscurePassword.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () => obscurePassword.value = !obscurePassword.value,
                                  ),
                                ),
                                obscureText: obscurePassword.value,
                                validator: (v) => validateRequired(v, label: 'Password'),
                                textInputAction: TextInputAction.done,
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (accountType.value == AccountType.member)
                        _SectionCard(
                          title: 'Personal info',
                          child: Column(
                            children: [
                              TextFormField(
                                controller: firstNameCtrl,
                                decoration: _inputDecoration('First name', Icons.badge),
                                validator: (v) => validateRequired(v, label: 'First name'),
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: lastNameCtrl,
                                decoration: _inputDecoration('Last name', Icons.badge_outlined),
                                validator: (v) => validateRequired(v, label: 'Last name'),
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 12),
                              _BirthDatePicker(
                                birthDate: birthDate.value,
                                onPick: isLoading ? null : chooseBirthDate,
                              ),
                            ],
                          ),
                        ),
                      if (accountType.value == AccountType.company)
                        Column(
                          children: [
                            _SectionCard(
                              title: 'Company',
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: companyNameCtrl,
                                    decoration: _inputDecoration('Company name', Icons.apartment),
                                    validator: (v) => validateRequired(v, label: 'Company name'),
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: websiteCtrl,
                                    decoration: _inputDecoration('Website', Icons.language),
                                    validator: (v) => validateRequired(v, label: 'Website'),
                                    keyboardType: TextInputType.url,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Location',
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: addressCtrl,
                                    decoration: _inputDecoration('Address', Icons.place),
                                    validator: (v) => validateRequired(v, label: 'Address'),
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: cityCtrl,
                                    decoration: _inputDecoration('City', Icons.location_city),
                                    validator: (v) => validateRequired(v, label: 'City'),
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: stateCtrl,
                                    decoration: _inputDecoration('State/Region', Icons.map),
                                    validator: (v) => validateRequired(v, label: 'State'),
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: countryCtrl,
                                    decoration: _inputDecoration('Country', Icons.flag),
                                    validator: (v) => validateRequired(v, label: 'Country'),
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: postalCtrl,
                                    decoration: _inputDecoration('Postal code', Icons.local_post_office),
                                    validator: (v) => validateRequired(v, label: 'Postal code'),
                                    textInputAction: TextInputAction.done,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Owners',
                              child: Column(
                                children: [
                                  for (int i = 0; i < owners.value.length; i++)
                                    _OwnerRow(
                                      index: i,
                                      owner: owners.value[i],
                                      onChanged: (o) => updateOwner(
                                        i,
                                        firstName: o.firstName,
                                        lastName: o.lastName,
                                      ),
                                      onRemove: owners.value.length > 1
                                          ? () => removeOwner(i)
                                          : null,
                                    ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: OutlinedButton.icon(
                                      onPressed: isLoading ? null : addOwner,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add owner'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                  ),
                                )
                              : const Text(
                                  'Create account',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                        child: const Text('Already have an account? Sign in'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
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

class _AccountTypeSelector extends StatelessWidget {
  const _AccountTypeSelector({required this.accountType});
  final ValueNotifier<AccountType> accountType;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AccountType>(
      segments: const [
        ButtonSegment(value: AccountType.member, icon: Icon(Icons.person), label: Text('Member')),
        ButtonSegment(value: AccountType.company, icon: Icon(Icons.business), label: Text('Company')),
      ],
      selected: {accountType.value},
      onSelectionChanged: (s) => accountType.value = s.first,
    );
  }
}

class _ImagePickerRow extends StatelessWidget {
  const _ImagePickerRow({required this.pickedPath, required this.onPick});
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

class _BirthDatePicker extends StatelessWidget {
  const _BirthDatePicker({required this.birthDate, required this.onPick});
  final DateTime? birthDate;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    final text = birthDate == null
        ? 'Select birth date'
        : '${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onPick,
      child: InputDecorator(
        decoration: _inputDecoration('Birth date', Icons.cake),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}

class _OwnerRow extends StatelessWidget {
  const _OwnerRow({
    required this.index,
    required this.owner,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final Owner owner;
  final ValueChanged<Owner> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final firstCtrl = TextEditingController(text: owner.firstName);
    final lastCtrl = TextEditingController(text: owner.lastName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: firstCtrl,
              decoration: const InputDecoration(
                labelText: 'First name',
                prefixIcon: Icon(Icons.badge),
              ),
              onChanged: (v) => onChanged(Owner(firstName: v, lastName: lastCtrl.text)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: lastCtrl,
              decoration: const InputDecoration(
                labelText: 'Last name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              onChanged: (v) => onChanged(Owner(firstName: firstCtrl.text, lastName: v)),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline),
            color: onRemove == null ? Colors.grey : AppColors.error,
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: AppColors.inputBackground,
  );
}
