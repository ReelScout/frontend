import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../components/signup/signup_form_components.dart';
import '../components/signup/account_form_section.dart';
import '../components/signup/member_form_section.dart';
import '../components/signup/company_form_sections.dart';
import '../dto/request/member_request_dto.dart';
import '../dto/request/production_company_request_dto.dart';
import '../dto/request/user_request_dto.dart';
import '../model/location.dart';
import '../model/owner.dart';
import '../styles/app_colors.dart';

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

    void updateOwner(int index, Owner owner) {
      final list = [...owners.value];
      list[index] = owner;
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
                      AccountTypeSelector(
                        accountType: accountType.value,
                        onChanged: (type) => accountType.value = type,
                      ),
                      const SizedBox(height: 16),
                      ImagePickerRow(
                        pickedPath: pickedImagePath.value,
                        onPick: isLoading ? null : pickImage,
                      ),
                      const SizedBox(height: 16),
                      AccountFormSection(
                        usernameController: usernameCtrl,
                        emailController: emailCtrl,
                        passwordController: passwordCtrl,
                        obscurePassword: obscurePassword.value,
                        onObscureToggle: () => obscurePassword.value = !obscurePassword.value,
                        isEnabled: !isLoading,
                      ),
                      const SizedBox(height: 16),
                      if (accountType.value == AccountType.member)
                        MemberFormSection(
                          firstNameController: firstNameCtrl,
                          lastNameController: lastNameCtrl,
                          birthDate: birthDate.value,
                          onBirthDatePick: chooseBirthDate,
                          isEnabled: !isLoading,
                        ),
                      if (accountType.value == AccountType.company)
                        CompanyFormSections(
                          companyNameController: companyNameCtrl,
                          websiteController: websiteCtrl,
                          addressController: addressCtrl,
                          cityController: cityCtrl,
                          stateController: stateCtrl,
                          countryController: countryCtrl,
                          postalController: postalCtrl,
                          owners: owners.value,
                          onAddOwner: addOwner,
                          onRemoveOwner: removeOwner,
                          onUpdateOwner: updateOwner,
                          isEnabled: !isLoading,
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

