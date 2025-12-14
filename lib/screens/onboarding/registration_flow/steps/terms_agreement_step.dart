import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';

class TermsAgreementStep extends ConsumerWidget {
  const TermsAgreementStep({Key? key})
      : super(key: key); // Removed controller parameter

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(registrationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms & Agreements',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Terms of Service
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Terms of Service',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'By using Hostelized, you agree to our Terms of Service. '
                    'This includes rules about payment, conduct, and termination of services.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  CheckboxListTile(
                    title: const Text('I agree to the Terms of Service'),
                    value: model.termsAccepted,
                    onChanged: (value) {
                      RegistrationController.updateAgreements(
                        ref,
                        termsAccepted: value ?? false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Privacy Policy
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Privacy Policy',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'We collect and use your personal data as described in our Privacy Policy. '
                    'This includes contact information, payment details, and usage data.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  CheckboxListTile(
                    title: const Text('I agree to the Privacy Policy'),
                    value: model.privacyAccepted,
                    onChanged: (value) {
                      RegistrationController.updateAgreements(
                        ref,
                        privacyAccepted: value ?? false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Marketing Communications
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Marketing Communications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'I would like to receive promotional emails and updates about Hostelized services.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  SwitchListTile(
                    title: const Text('Receive marketing emails'),
                    value: false,
                    onChanged: (value) {
                      // Optional: Add marketing preference to model
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'You must accept both Terms of Service and Privacy Policy to continue.',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
