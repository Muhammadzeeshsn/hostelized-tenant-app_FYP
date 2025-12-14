import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'registration_model.dart';

// Provider for registration data
final registrationProvider = StateProvider<RegistrationModel>((ref) {
  return RegistrationModel();
});

// Provider for current step
final currentStepProvider = StateProvider<int>((ref) => 0);

// Provider for total steps
final totalStepsProvider = Provider<int>((ref) => 9);

// Helper class with static methods
class RegistrationController {
  // Navigation
  static void nextStep(WidgetRef ref) {
    final current = ref.read(currentStepProvider);
    final total = ref.read(totalStepsProvider);
    if (current < total - 1) {
      ref.read(currentStepProvider.notifier).state = current + 1;
    }
  }

  static void previousStep(WidgetRef ref) {
    final current = ref.read(currentStepProvider);
    if (current > 0) {
      ref.read(currentStepProvider.notifier).state = current - 1;
    }
  }

  static void goToStep(WidgetRef ref, int step) {
    final total = ref.read(totalStepsProvider);
    if (step >= 0 && step < total) {
      ref.read(currentStepProvider.notifier).state = step;
    }
  }

  // Data update methods
  static void updatePersonalInfo(
    WidgetRef ref, {
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    final currentState = ref.read(registrationProvider);
    ref.read(registrationProvider.notifier).state = currentState.copyWith(
      firstName: firstName?.trim() ?? currentState.firstName,
      lastName: lastName?.trim() ?? currentState.lastName,
      email: email?.trim() ?? currentState.email,
      phoneNumber: phoneNumber?.trim() ?? currentState.phoneNumber,
      dateOfBirth: dateOfBirth ?? currentState.dateOfBirth,
      gender: gender?.trim() ?? currentState.gender,
    );

    // Debug: Log the update
    print(
        '✅ UPDATED Personal Info: $firstName $lastName, $email, $phoneNumber');
  }

  static void updateContactDetails(
    WidgetRef ref, {
    String? personalEmail,
    String? emergencyPhone,
    String? alternatePhone,
  }) {
    final currentState = ref.read(registrationProvider);
    ref.read(registrationProvider.notifier).state = currentState.copyWith(
      personalEmail: personalEmail?.trim() ?? currentState.personalEmail,
      emergencyPhone: emergencyPhone?.trim() ?? currentState.emergencyPhone,
      alternatePhone: alternatePhone?.trim() ?? currentState.alternatePhone,
    );
  }

  static void updateAddress(
    WidgetRef ref, {
    String? currentAddress,
    String? permanentAddress,
    String? city,
    String? state,
    String? country,
    String? postalCode,
  }) {
    final currentState = ref.read(registrationProvider);
    ref.read(registrationProvider.notifier).state = currentState.copyWith(
      currentAddress: currentAddress?.trim() ?? currentState.currentAddress,
      permanentAddress:
          permanentAddress?.trim() ?? currentState.permanentAddress,
      city: city?.trim() ?? currentState.city,
      state: state?.trim() ?? currentState.state,
      country: country?.trim() ?? currentState.country,
      postalCode: postalCode?.trim() ?? currentState.postalCode,
    );
  }

  static void updateJobDetails(
    WidgetRef ref, {
    String? employmentStatus,
    String? companyName,
    String? jobTitle,
    String? workEmail,
    String? workPhone,
    String? monthlyIncome,
  }) {
    final currentState = ref.read(registrationProvider);
    ref.read(registrationProvider.notifier).state = currentState.copyWith(
      employmentStatus:
          employmentStatus?.trim() ?? currentState.employmentStatus,
      companyName: companyName?.trim() ?? currentState.companyName,
      jobTitle: jobTitle?.trim() ?? currentState.jobTitle,
      workEmail: workEmail?.trim() ?? currentState.workEmail,
      workPhone: workPhone?.trim() ?? currentState.workPhone,
      monthlyIncome: monthlyIncome?.trim() ?? currentState.monthlyIncome,
    );
  }

  static void updateStudyDetails(
    WidgetRef ref, {
    bool? isStudent,
    String? institutionName,
    String? courseName,
    String? studentId,
    String? yearOfStudy,
  }) {
    final currentState = ref.read(registrationProvider);
    ref.read(registrationProvider.notifier).state = currentState.copyWith(
      isStudent: isStudent ?? currentState.isStudent,
      institutionName: institutionName?.trim() ?? currentState.institutionName,
      courseName: courseName?.trim() ?? currentState.courseName,
      studentId: studentId?.trim() ?? currentState.studentId,
      yearOfStudy: yearOfStudy?.trim() ?? currentState.yearOfStudy,
    );
  }

  static void addEmergencyContact(WidgetRef ref, Map<String, String> contact) {
    final currentState = ref.read(registrationProvider);
    final trimmedContact = {
      'name': contact['name']?.trim() ?? '',
      'phone': contact['phone']?.trim() ?? '',
      'relationship': contact['relationship']?.trim() ?? '',
    };
    final newContacts = [...currentState.emergencyContacts, trimmedContact];
    ref.read(registrationProvider.notifier).state =
        currentState.copyWith(emergencyContacts: newContacts);
  }

  static void removeEmergencyContact(WidgetRef ref, int index) {
    final currentState = ref.read(registrationProvider);
    final newContacts =
        List<Map<String, String>>.from(currentState.emergencyContacts);
    if (index >= 0 && index < newContacts.length) {
      newContacts.removeAt(index);
    }
    ref.read(registrationProvider.notifier).state =
        currentState.copyWith(emergencyContacts: newContacts);
  }

  static void updateAgreements(
    WidgetRef ref, {
    bool? termsAccepted,
    bool? privacyAccepted,
  }) {
    final currentState = ref.read(registrationProvider);
    ref.read(registrationProvider.notifier).state = currentState.copyWith(
      termsAccepted: termsAccepted ?? currentState.termsAccepted,
      privacyAccepted: privacyAccepted ?? currentState.privacyAccepted,
    );
  }

  static void updateProfilePicture(WidgetRef ref, String? imagePath) {
    final currentState = ref.read(registrationProvider);
    ref.read(registrationProvider.notifier).state =
        currentState.copyWith(profileImagePath: imagePath?.trim());
  }

  // Validation - Boolean check (SIMPLIFIED VERSION - FOR TESTING)
  static bool isCurrentStepValid(WidgetRef ref) {
    final current = ref.read(currentStepProvider);
    final model = ref.read(registrationProvider);

    // Debug: Force print the current state
    print('🚨 VALIDATION CHECK - Step $current');
    print(
        'First Name: "${model.firstName}" (length: ${model.firstName.length})');
    print('Last Name: "${model.lastName}" (length: ${model.lastName.length})');
    print('Email: "${model.email}" (length: ${model.email.length})');
    print(
        'Phone: "${model.phoneNumber}" (length: ${model.phoneNumber.length})');

    switch (current) {
      case 0:
        // Step 0: Personal Information - SIMPLIFIED FOR NOW
        // Just check if fields are not empty
        final firstNameValid = model.firstName.trim().isNotEmpty;
        final lastNameValid = model.lastName.trim().isNotEmpty;
        final emailValid = model.email.trim().isNotEmpty;
        final phoneValid = model.phoneNumber.trim().isNotEmpty;

        print('✅ Step 0 Validation Results:');
        print('   First Name: $firstNameValid');
        print('   Last Name: $lastNameValid');
        print('   Email: $emailValid');
        print('   Phone: $phoneValid');
        print(
            '   Overall: ${firstNameValid && lastNameValid && emailValid && phoneValid}');

        return firstNameValid && lastNameValid && emailValid && phoneValid;

      case 1:
        // Step 1: Contact Details
        return model.personalEmail.trim().isNotEmpty;

      case 2:
        // Step 2: Address
        return model.currentAddress.trim().isNotEmpty &&
            model.city.trim().isNotEmpty;

      case 3:
        // Step 3: Job Details
        return model.employmentStatus.trim().isNotEmpty;

      case 4:
        // Step 4: Study Details - Optional
        return true;

      case 5:
        // Step 5: Emergency Contacts
        return model.emergencyContacts.isNotEmpty;

      case 6:
        // Step 6: Terms Agreement
        return model.termsAccepted && model.privacyAccepted;

      case 7:
        // Step 7: Profile Picture
        return model.profileImagePath != null &&
            model.profileImagePath!.trim().isNotEmpty;

      case 8:
        // Step 8: Review - Always valid
        return true;

      default:
        return false;
    }
  }

  // Validation - Get detailed error message (SIMPLIFIED)
  static String? getCurrentStepValidationMessage(WidgetRef ref) {
    final current = ref.read(currentStepProvider);
    final model = ref.read(registrationProvider);

    switch (current) {
      case 0:
        if (model.firstName.trim().isEmpty) return 'First name is required';
        if (model.lastName.trim().isEmpty) return 'Last name is required';
        if (model.email.trim().isEmpty) return 'Email is required';
        if (model.phoneNumber.trim().isEmpty) return 'Phone number is required';
        return null;

      case 1:
        if (model.personalEmail.trim().isEmpty)
          return 'Personal email is required';
        return null;

      case 2:
        if (model.currentAddress.trim().isEmpty)
          return 'Current address is required';
        if (model.city.trim().isEmpty) return 'City is required';
        return null;

      case 3:
        if (model.employmentStatus.trim().isEmpty)
          return 'Please select your employment status';
        return null;

      case 5:
        if (model.emergencyContacts.isEmpty)
          return 'At least one emergency contact is required';
        return null;

      case 6:
        if (!model.termsAccepted) return 'Please accept the Terms of Service';
        if (!model.privacyAccepted) return 'Please accept the Privacy Policy';
        return null;

      case 7:
        if (model.profileImagePath == null ||
            model.profileImagePath!.trim().isEmpty) {
          return 'Profile picture is required';
        }
        return null;

      default:
        return null;
    }
  }

  static void reset(WidgetRef ref) {
    ref.read(registrationProvider.notifier).state = RegistrationModel();
    ref.read(currentStepProvider.notifier).state = 0;
  }

  // Submit registration to API
  static Future<void> submitRegistration(WidgetRef ref) async {
    final model = ref.read(registrationProvider);

    print('🎯 SUBMITTING REGISTRATION:');
    print('   Name: ${model.firstName} ${model.lastName}');
    print('   Email: ${model.email}');
    print('   Phone: ${model.phoneNumber}');

    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 2));

    print('✅ REGISTRATION SUBMITTED SUCCESSFULLY');
    return;
  }

  // Debug method to print current state
  static void debugPrintState(WidgetRef ref) {
    final model = ref.read(registrationProvider);

    print('🔍 DEBUG - CURRENT REGISTRATION STATE:');
    print(
        '   First Name: "${model.firstName}" (length: ${model.firstName.length})');
    print(
        '   Last Name: "${model.lastName}" (length: ${model.lastName.length})');
    print('   Email: "${model.email}" (length: ${model.email.length})');
    print(
        '   Phone: "${model.phoneNumber}" (length: ${model.phoneNumber.length})');
    print('   Gender: "${model.gender}"');
    print('   Date of Birth: ${model.dateOfBirth}');
    print('   Terms Accepted: ${model.termsAccepted}');
    print('   Privacy Accepted: ${model.privacyAccepted}');
    print('   Profile Image: ${model.profileImagePath}');
    print('   Emergency Contacts: ${model.emergencyContacts.length}');
  }
}
