import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';
import '../registration_model.dart';

class ContactDetailsStep extends ConsumerWidget {
  const ContactDetailsStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(registrationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Provide your contact information',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Personal Email
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Personal Email',
              border: OutlineInputBorder(),
              hintText: 'example@gmail.com',
            ),
            initialValue: model.personalEmail,
            onChanged: (value) {
              RegistrationController.updateContactDetails(
                ref,
                personalEmail: value,
              );
            },
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),

          // Emergency Phone
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Emergency Phone',
              border: OutlineInputBorder(),
              hintText: '+923001234567',
            ),
            initialValue: model.emergencyPhone,
            onChanged: (value) {
              RegistrationController.updateContactDetails(
                ref,
                emergencyPhone: value,
              );
            },
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),

          // Alternate Phone
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Alternate Phone (Optional)',
              border: OutlineInputBorder(),
              hintText: '+923001234567',
            ),
            initialValue: model.alternatePhone,
            onChanged: (value) {
              RegistrationController.updateContactDetails(
                ref,
                alternatePhone: value,
              );
            },
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Emergency phone will be used in case we cannot reach you on your primary number.',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
