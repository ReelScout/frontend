import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../model/owner.dart';
import 'signup_form_components.dart';

class CompanyFormSections extends HookWidget {
  const CompanyFormSections({
    super.key,
    required this.companyNameController,
    required this.websiteController,
    required this.addressController,
    required this.cityController,
    required this.stateController,
    required this.countryController,
    required this.postalController,
    required this.owners,
    required this.onAddOwner,
    required this.onRemoveOwner,
    required this.onUpdateOwner,
    this.isEnabled = true,
  });

  final TextEditingController companyNameController;
  final TextEditingController websiteController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController countryController;
  final TextEditingController postalController;
  final List<Owner> owners;
  final VoidCallback onAddOwner;
  final Function(int) onRemoveOwner;
  final Function(int, Owner) onUpdateOwner;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Company Information
        SectionCard(
          title: 'Company',
          child: Column(
            children: [
              TextFormField(
                controller: companyNameController,
                decoration: signupInputDecoration('Company name', Icons.apartment),
                validator: (v) => SignupValidators.validateRequired(v, label: 'Company name'),
                textInputAction: TextInputAction.next,
                enabled: isEnabled,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: websiteController,
                decoration: signupInputDecoration('Website', Icons.language),
                validator: (v) => SignupValidators.validateRequired(v, label: 'Website'),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                enabled: isEnabled,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Location Information
        SectionCard(
          title: 'Location',
          child: Column(
            children: [
              TextFormField(
                controller: addressController,
                decoration: signupInputDecoration('Address', Icons.place),
                validator: (v) => SignupValidators.validateRequired(v, label: 'Address'),
                textInputAction: TextInputAction.next,
                enabled: isEnabled,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cityController,
                decoration: signupInputDecoration('City', Icons.location_city),
                validator: (v) => SignupValidators.validateRequired(v, label: 'City'),
                textInputAction: TextInputAction.next,
                enabled: isEnabled,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: stateController,
                decoration: signupInputDecoration('State/Region', Icons.map),
                validator: (v) => SignupValidators.validateRequired(v, label: 'State'),
                textInputAction: TextInputAction.next,
                enabled: isEnabled,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: countryController,
                decoration: signupInputDecoration('Country', Icons.flag),
                validator: (v) => SignupValidators.validateRequired(v, label: 'Country'),
                textInputAction: TextInputAction.next,
                enabled: isEnabled,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: postalController,
                decoration: signupInputDecoration('Postal code', Icons.local_post_office),
                validator: (v) => SignupValidators.validateRequired(v, label: 'Postal code'),
                textInputAction: TextInputAction.done,
                enabled: isEnabled,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Owners Section
        SectionCard(
          title: 'Owners',
          child: Column(
            children: [
              for (int i = 0; i < owners.length; i++)
                OwnerRow(
                  key: ValueKey('owner_$i'),
                  index: i,
                  owner: owners[i],
                  onChanged: (owner) => onUpdateOwner(i, owner),
                  onRemove: owners.length > 1 && isEnabled ? () => onRemoveOwner(i) : null,
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: isEnabled ? onAddOwner : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Add owner'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
