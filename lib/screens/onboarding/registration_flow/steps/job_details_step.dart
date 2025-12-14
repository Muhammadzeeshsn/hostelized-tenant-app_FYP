import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';
import '../registration_model.dart';

class JobDetailsStep extends ConsumerWidget {
  const JobDetailsStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(registrationProvider);

    // Employment status options
    final employmentOptions = [
      'Employed Full-time',
      'Employed Part-time',
      'Self-employed',
      'Unemployed',
      'Student',
      'Retired',
      'Other',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Employment Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tell us about your current employment status',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Employment Status Dropdown
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Employment Status',
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: model.employmentStatus.isNotEmpty
                    ? model.employmentStatus
                    : null,
                hint: const Text('Select employment status'),
                isExpanded: true,
                items: employmentOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  RegistrationController.updateJobDetails(
                    ref,
                    employmentStatus: value ?? '',
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Company Name
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Company/Organization Name',
              border: OutlineInputBorder(),
              hintText: 'ABC Corporation',
            ),
            initialValue: model.companyName,
            onChanged: (value) {
              RegistrationController.updateJobDetails(
                ref,
                companyName: value,
              );
            },
          ),
          const SizedBox(height: 15),

          // Job Title
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Job Title/Position',
              border: OutlineInputBorder(),
              hintText: 'Software Engineer',
            ),
            initialValue: model.jobTitle,
            onChanged: (value) {
              RegistrationController.updateJobDetails(
                ref,
                jobTitle: value,
              );
            },
          ),
          const SizedBox(height: 15),

          // Work Email
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Work Email (Optional)',
              border: OutlineInputBorder(),
              hintText: 'john@company.com',
            ),
            initialValue: model.workEmail,
            onChanged: (value) {
              RegistrationController.updateJobDetails(
                ref,
                workEmail: value,
              );
            },
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),

          // Work Phone
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Work Phone (Optional)',
              border: OutlineInputBorder(),
              hintText: '+923001234567',
            ),
            initialValue: model.workPhone,
            onChanged: (value) {
              RegistrationController.updateJobDetails(
                ref,
                workPhone: value,
              );
            },
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),

          // Monthly Income
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Monthly Income (Optional)',
              border: OutlineInputBorder(),
              hintText: '50000',
              prefixText: 'PKR ',
            ),
            initialValue: model.monthlyIncome,
            onChanged: (value) {
              RegistrationController.updateJobDetails(
                ref,
                monthlyIncome: value,
              );
            },
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Employment information helps us understand your financial stability for rental agreements.',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
