// lib/screens/onboarding/registration_flow/tenant_registration_flow.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Use relative imports
import 'imports.dart';

class TenantRegistrationFlow extends ConsumerWidget {
  const TenantRegistrationFlow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(currentStepProvider);
    final totalSteps = ref.read(totalStepsProvider);

    // CRITICAL FIX: Watch the registration provider so validation recalculates on changes
    ref.watch(registrationProvider);
    final isCurrentStepValid = RegistrationController.isCurrentStepValid(ref);

    // Create steps (6 steps total)
    final steps = [
      const PersonalInfoStep(), // Step 1
      const AddressDetailsStep(), // Step 2
      const PurposeOfStayStep(), // Step 3
      const IdentityDocumentsStep(), // Step 4
      const GuardianDetailsStep(), // Step 5
      const PhotoVerificationStep(), // Step 6
    ];

    void skipRegistration() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Skip Registration?'),
          content: const Text(
            'You can complete this registration later from your profile.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                RegistrationController.reset(ref);
                // Use GoRouter navigation
                context.go('/dashboard');
              },
              child: const Text('Skip', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    void _showValidationError() {
      final errorMessage =
          RegistrationController.getCurrentStepValidationMessage(ref) ??
              'Please complete all required fields';

      // Show a snackbar for better UX
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      // Haptic feedback for error
      HapticFeedback.lightImpact();
    }

    void _submitRegistration() async {
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Submitting registration...'),
              ],
            ),
          ),
        );

        // Submit registration
        await RegistrationController.submitRegistration(ref);

        // Close loading dialog
        if (context.mounted) {
          Navigator.pop(context);
        }

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Complete!'),
            content: const Text(
                'Your registration has been submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  RegistrationController.reset(ref);
                  context.go('/dashboard');
                },
                child: const Text('Continue to Dashboard'),
              ),
            ],
          ),
        );
      } catch (error) {
        // Close loading dialog
        if (context.mounted) {
          Navigator.pop(context);
        }

        // Show error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Submission Failed'),
            content: Text('Error: $error\nPlease try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }

    void handleNext() {
      // Debug: Print current registration state
      final model = ref.read(registrationProvider);
      print('=== DEBUG: Current Registration State ===');
      print(
          'First Name: "${model.firstName}" (length: ${model.firstName.length})');
      print(
          'Last Name: "${model.lastName}" (length: ${model.lastName.length})');
      print('Email: "${model.email}" (length: ${model.email.length})');
      print(
          'Phone: "${model.phoneNumber}" (length: ${model.phoneNumber.length})');
      print('Gender: "${model.gender}"');
      print('Date of Birth: ${model.dateOfBirth}');
      print('isCurrentStepValid: $isCurrentStepValid');
      print(
          'Validation Message: ${RegistrationController.getCurrentStepValidationMessage(ref)}');
      print('=========================================');

      if (isCurrentStepValid) {
        if (currentStep == totalSteps - 1) {
          _submitRegistration();
        } else {
          RegistrationController.nextStep(ref);
        }
      } else {
        _showValidationError();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Registration'),
        actions: [
          TextButton(
            onPressed: skipRegistration,
            child: const Text('Skip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar with better styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= currentStep
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${currentStep + 1} of $totalSteps',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${((currentStep + 1) / totalSteps * 100).round()}% Complete',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Current Step
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: steps[currentStep],
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentStep > 0)
                  OutlinedButton(
                    onPressed: () => RegistrationController.previousStep(ref),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, size: 18),
                        SizedBox(width: 8),
                        Text('Back'),
                      ],
                    ),
                  )
                else
                  const SizedBox(width: 100),
                ElevatedButton(
                  onPressed: handleNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    backgroundColor: isCurrentStepValid
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400],
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Text(currentStep == totalSteps - 1 ? 'Submit' : 'Next'),
                      const SizedBox(width: 8),
                      if (currentStep < totalSteps - 1)
                        const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
