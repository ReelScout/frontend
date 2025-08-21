import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

import '../../dto/request/member_request_dto.dart';
import '../../dto/request/production_company_request_dto.dart';
import '../../dto/request/user_request_dto.dart';
import '../../dto/response/member_response_dto.dart';
import '../../dto/response/production_company_response_dto.dart';
import '../../dto/response/user_response_dto.dart';
import '../../model/location.dart';
import '../../model/owner.dart';
import '../../styles/app_colors.dart';
import '../signup/signup_form_components.dart';
import '../signup/account_form_section.dart';
import '../signup/member_form_section.dart';
import '../signup/company_form_sections.dart';

class UserFormWrapper extends HookWidget {
  const UserFormWrapper({
    super.key,
    required this.title,
    required this.submitButtonText,
    required this.onSubmit,
    this.showAccountTypeSelector = false,
    this.existingUser,
    this.isLoading = false,
    this.bottomAction,
  });

  final String title;
  final String submitButtonText;
  final Function(UserRequestDto request) onSubmit;
  final bool showAccountTypeSelector;
  final UserResponseDto? existingUser;
  final bool isLoading;
  final Widget? bottomAction;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Common fields
    final accountType = useState(AccountType.member);
    final usernameCtrl = useTextEditingController(text: existingUser?.username ?? '');
    final emailCtrl = useTextEditingController(text: existingUser?.email ?? '');
    final passwordCtrl = useTextEditingController();
    final obscurePassword = useState(true);
    final base64Image = useState<String?>(existingUser?.base64Image);
    final pickedImagePath = useState<String?>(null);

    // Member fields
    final firstNameCtrl = useTextEditingController(
      text: existingUser is MemberResponseDto ? (existingUser as MemberResponseDto).firstName : '',
    );
    final lastNameCtrl = useTextEditingController(
      text: existingUser is MemberResponseDto ? (existingUser as MemberResponseDto).lastName : '',
    );
    final birthDate = useState<DateTime?>(
      existingUser is MemberResponseDto ? (existingUser as MemberResponseDto).birthDate : null,
    );

    // Company fields
    final companyNameCtrl = useTextEditingController(
      text: existingUser is ProductionCompanyResponseDto ? (existingUser as ProductionCompanyResponseDto).name : '',
    );
    final websiteCtrl = useTextEditingController(
      text: existingUser is ProductionCompanyResponseDto ? (existingUser as ProductionCompanyResponseDto).website : '',
    );
    final addressCtrl = useTextEditingController(
      text: existingUser is ProductionCompanyResponseDto ? (existingUser as ProductionCompanyResponseDto).location.address : '',
    );
    final cityCtrl = useTextEditingController(
      text: existingUser is ProductionCompanyResponseDto ? (existingUser as ProductionCompanyResponseDto).location.city : '',
    );
    final stateCtrl = useTextEditingController(
      text: existingUser is ProductionCompanyResponseDto ? (existingUser as ProductionCompanyResponseDto).location.state : '',
    );
    final countryCtrl = useTextEditingController(
      text: existingUser is ProductionCompanyResponseDto ? (existingUser as ProductionCompanyResponseDto).location.country : '',
    );
    final postalCtrl = useTextEditingController(
      text: existingUser is ProductionCompanyResponseDto ? (existingUser as ProductionCompanyResponseDto).location.postalCode : '',
    );
    final owners = useState<List<Owner>>(
      existingUser is ProductionCompanyResponseDto 
        ? List<Owner>.from((existingUser as ProductionCompanyResponseDto).owners) 
        : [Owner(firstName: '', lastName: '')],
    );

    // Determine if we're dealing with member or company based on existing user or account type
    final isCompanyAccount = existingUser is ProductionCompanyResponseDto || 
        (existingUser == null && accountType.value == AccountType.company);

    Future<void> pickImage() async {
      try {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 75,
        );
        if (image != null) {
          final bytes = await image.readAsBytes();
          base64Image.value = base64Encode(bytes);
          pickedImagePath.value = base64Image.value;
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image pick failed: $e'), backgroundColor: AppColors.error),
          );
        }
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

      final String username = usernameCtrl.text.trim();
      final String email = emailCtrl.text.trim();
      final String password = passwordCtrl.text;

      UserRequestDto request;

      if (isCompanyAccount) {
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
      } else {
        // Member account
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
      }

      onSubmit(request);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(title),
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
                if (showAccountTypeSelector) ...[
                  AccountTypeSelector(
                    accountType: accountType.value,
                    onChanged: (type) => accountType.value = type,
                  ),
                  const SizedBox(height: 16),
                ],
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
                if (!isCompanyAccount)
                  MemberFormSection(
                    firstNameController: firstNameCtrl,
                    lastNameController: lastNameCtrl,
                    birthDate: birthDate.value,
                    onBirthDatePick: chooseBirthDate,
                    isEnabled: !isLoading,
                  ),
                if (isCompanyAccount)
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
                        : Text(
                            submitButtonText,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                if (bottomAction != null) ...[
                  const SizedBox(height: 8),
                  bottomAction!,
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}