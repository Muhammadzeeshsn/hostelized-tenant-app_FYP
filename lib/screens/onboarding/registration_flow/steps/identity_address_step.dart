// lib/screens/onboarding/registration_flow/steps/identity_address_step.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';

class IdentityAddressStep extends ConsumerWidget {
  const IdentityAddressStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(registrationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Identity & Address Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Current Address
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Current Address',
              border: OutlineInputBorder(),
            ),
            initialValue: model.currentAddress,
            onChanged: (value) {
              RegistrationController.updateAddress(
                ref,
                currentAddress: value,
              );
            },
          ),
          const SizedBox(height: 15),

          // City
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(),
            ),
            initialValue: model.city,
            onChanged: (value) {
              RegistrationController.updateAddress(
                ref,
                city: value,
              );
            },
          ),
          const SizedBox(height: 15),

          // State
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'State',
              border: OutlineInputBorder(),
            ),
            initialValue: model.state,
            onChanged: (value) {
              RegistrationController.updateAddress(
                ref,
                state: value,
              );
            },
          ),
          const SizedBox(height: 15),

          // Country
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Country',
              border: OutlineInputBorder(),
            ),
            initialValue: model.country,
            onChanged: (value) {
              RegistrationController.updateAddress(
                ref,
                country: value,
              );
            },
          ),
          const SizedBox(height: 15),

          // Postal Code
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Postal Code',
              border: OutlineInputBorder(),
            ),
            initialValue: model.postalCode,
            onChanged: (value) {
              RegistrationController.updateAddress(
                ref,
                postalCode: value,
              );
            },
          ),
          const SizedBox(height: 15),

          // Permanent Address
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Permanent Address',
              border: OutlineInputBorder(),
            ),
            initialValue: model.permanentAddress,
            onChanged: (value) {
              RegistrationController.updateAddress(
                ref,
                permanentAddress: value,
              );
            },
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
