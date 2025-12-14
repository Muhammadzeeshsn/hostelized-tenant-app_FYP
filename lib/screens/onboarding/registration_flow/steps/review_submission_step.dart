import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';

class ReviewSubmissionStep extends ConsumerWidget {
  const ReviewSubmissionStep({Key? key})
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
            'Review & Submit',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Please review all your information before submitting',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Personal Info
          _buildSection(
            title: 'Personal Information',
            children: [
              _buildInfoRow('Name', '${model.firstName} ${model.lastName}'),
              _buildInfoRow('Email', model.email),
              _buildInfoRow('Phone', model.phoneNumber),
              _buildInfoRow('Gender', model.gender),
              if (model.dateOfBirth != null)
                _buildInfoRow('Date of Birth',
                    model.dateOfBirth.toString().split(' ')[0]),
            ],
          ),

          const SizedBox(height: 20),

          // Address
          _buildSection(
            title: 'Address',
            children: [
              _buildInfoRow('Current Address', model.currentAddress),
              _buildInfoRow('City', model.city),
              _buildInfoRow('State', model.state),
              _buildInfoRow('Country', model.country),
            ],
          ),

          const SizedBox(height: 20),

          // Emergency Contacts
          _buildSection(
            title: 'Emergency Contacts',
            children: model.emergencyContacts.isEmpty
                ? [
                    const Text('No contacts added',
                        style: TextStyle(color: Colors.grey))
                  ]
                : model.emergencyContacts
                    .map((contact) =>
                        Text('${contact['name']} - ${contact['phone']}'))
                    .toList(),
          ),

          const SizedBox(height: 30),

          // Terms Agreement
          Row(
            children: [
              Icon(
                model.termsAccepted && model.privacyAccepted
                    ? Icons.check_circle
                    : Icons.cancel,
                color: model.termsAccepted && model.privacyAccepted
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Terms & Privacy Policy Accepted'),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Submit Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Handle submission
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Registration submitted successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: const Text('Submit Registration'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
        const Divider(height: 30),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value.isEmpty ? 'Not provided' : value),
          ),
        ],
      ),
    );
  }
}
