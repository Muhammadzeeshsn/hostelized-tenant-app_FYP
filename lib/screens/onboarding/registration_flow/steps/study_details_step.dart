import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';
import '../registration_model.dart';

class StudyDetailsStep extends ConsumerWidget {
  const StudyDetailsStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(registrationProvider);

    // Year of study options
    final yearOptions = [
      '1st Year',
      '2nd Year',
      '3rd Year',
      '4th Year',
      '5th Year+'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Study Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tell us about your educational background (Optional)',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Are you a student?
          SwitchListTile(
            title: const Text(
              'Are you currently a student?',
              style: TextStyle(fontSize: 16),
            ),
            value: model.isStudent,
            onChanged: (value) {
              RegistrationController.updateStudyDetails(
                ref,
                isStudent: value,
              );
            },
          ),

          const SizedBox(height: 20),

          if (model.isStudent) ...[
            // Institution Name
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Institution Name',
                border: OutlineInputBorder(),
                hintText: 'University of Engineering and Technology',
              ),
              initialValue: model.institutionName,
              onChanged: (value) {
                RegistrationController.updateStudyDetails(
                  ref,
                  institutionName: value,
                );
              },
            ),
            const SizedBox(height: 15),

            // Course Name
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Course/Program',
                border: OutlineInputBorder(),
                hintText: 'Computer Science',
              ),
              initialValue: model.courseName,
              onChanged: (value) {
                RegistrationController.updateStudyDetails(
                  ref,
                  courseName: value,
                );
              },
            ),
            const SizedBox(height: 15),

            // Student ID
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Student ID (Optional)',
                border: OutlineInputBorder(),
                hintText: 'CS-2020-001',
              ),
              initialValue: model.studentId,
              onChanged: (value) {
                RegistrationController.updateStudyDetails(
                  ref,
                  studentId: value,
                );
              },
            ),
            const SizedBox(height: 15),

            // Year of Study Dropdown
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Year of Study',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value:
                      model.yearOfStudy.isNotEmpty ? model.yearOfStudy : null,
                  hint: const Text('Select year of study'),
                  isExpanded: true,
                  items: yearOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    RegistrationController.updateStudyDetails(
                      ref,
                      yearOfStudy: value ?? '',
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Student information helps us provide you with relevant offers and accommodations.',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
          ] else ...[
            const SizedBox(height: 100),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No study details required',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'You can skip this section if you are not a student',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
