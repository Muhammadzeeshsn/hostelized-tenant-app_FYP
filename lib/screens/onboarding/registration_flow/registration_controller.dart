// lib/screens/onboarding/registration_flow/registration_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'registration_model.dart';

// Provider for registration data
final registrationProvider = StateProvider<RegistrationModel>((ref) {
  return RegistrationModel();
});

// Provider for current step
final currentStepProvider = StateProvider<int>((ref) => 0);

// Provider for total steps (reduced to 6)
final totalStepsProvider = Provider<int>((ref) => 6);

// Helper class with static methods
class RegistrationController {
  // ============================================================================
  // NAVIGATION
  // ============================================================================

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

  // ============================================================================
  // DATA UPDATE METHODS
  // ============================================================================

  // Step 1: Personal Information
  static void updatePersonalInfo(
    WidgetRef ref, {
    String? firstName,
    String? lastName,
    String? gender,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) {
    final currentState = ref.read(registrationProvider);
    ref.read(registrationProvider.notifier).state = currentState.copyWith(
      firstName: firstName?.trim(),
      lastName: lastName?.trim(),
      gender: gender?.trim(),
      email: email?.trim(),
      phoneNumber: phoneNumber?.trim(),
      dateOfBirth: dateOfBirth,
    );
  }

  // Step 2: Address Details
  static void updateAddress(
    WidgetRef ref, {
    String? currentCountry,
    String? currentCity,
    String? currentAddress,
    String? permanentCountry,
    String? permanentCity,
    String? permanentAddress,
    bool? sameAsCurrent,
  }) {
    final currentState = ref.read(registrationProvider);

    // If "same as current" is checked, copy current address to permanent
    if (sameAsCurrent == true) {
      ref.read(registrationProvider.notifier).state = currentState.copyWith(
        currentCountry: currentCountry?.trim(),
        currentCity: currentCity?.trim(),
        currentAddress: currentAddress?.trim(),
        permanentCountry: currentState.currentCountry,
        permanentCity: currentState.currentCity,
        permanentAddress: currentState.currentAddress,
        sameAsCurrent: true,
      );
    } else {
      ref.read(registrationProvider.notifier).state = currentState.copyWith(
        currentCountry: currentCountry?.trim(),
        currentCity: currentCity?.trim(),
        currentAddress: currentAddress?.trim(),
        permanentCountry: permanentCountry?.trim(),
        permanentCity: permanentCity?.trim(),
        permanentAddress: permanentAddress?.trim(),
        sameAsCurrent: sameAsCurrent,
      );
    }
  }

  // Step 3: Purpose of Stay
  static void updatePurposeOfStay(
    WidgetRef ref, {
    String? purposeOfStay,
    String? institutionName,
    String? courseDegree,
    String? registrationNumber,
    String? jobBusinessDetails,
    String? businessStreetAddress,
    String? designation,
    String? otherPurposeDetails,
  }) {
    final currentState = ref.read(registrationProvider);
    ref.read(registrationProvider.notifier).state = currentState.copyWith(
      purposeOfStay: purposeOfStay?.trim(),
      institutionName: institutionName?.trim(),
      courseDegree: courseDegree?.trim(),
      registrationNumber: registrationNumber?.trim(),
      jobBusinessDetails: jobBusinessDetails?.trim(),
      businessStreetAddress: businessStreetAddress?.trim(),
      designation: designation?.trim(),
      otherPurposeDetails: otherPurposeDetails?.trim(),
    );
  }

  // Step 4: Identity Documents
  static void updateIdentityDocuments(
    WidgetRef ref, {
    String? documentType,
    String? documentNumber,
    String? documentImagePath,
    String? documentBackImagePath,
  }) {
    final currentState = ref.read(registrationProvider);
    ref.read(registrationProvider.notifier).state = currentState.copyWith(
      documentType: documentType?.trim(),
      documentNumber: documentNumber?.trim(),
      documentImagePath: documentImagePath?.trim(),
      documentBackImagePath: documentBackImagePath?.trim(),
    );
  }

  // Step 5: Guardian Details
  static void updateGuardianDetails(
    WidgetRef ref, {
    String? guardianName,
    String? guardianPhone,
    String? guardianRelation,
  }) {
    final currentState = ref.read(registrationProvider);
    ref.read(registrationProvider.notifier).state = currentState.copyWith(
      guardianName: guardianName?.trim(),
      guardianPhone: guardianPhone?.trim(),
      guardianRelation: guardianRelation?.trim(),
    );
  }

  // Step 6: Photo Verification
  static void updatePhotoVerification(
    WidgetRef ref, {
    String? profileImagePath,
    String? faceEncodingData,
    bool? isFaceVerified,
    bool? photoFromCamera,
    bool? hostelPoliciesAccepted,
    bool? termsConditionsAccepted,
  }) {
    final currentState = ref.read(registrationProvider);
    ref.read(registrationProvider.notifier).state = currentState.copyWith(
      profileImagePath: profileImagePath?.trim(),
      faceEncodingData: faceEncodingData?.trim(),
      isFaceVerified: isFaceVerified,
      photoFromCamera: photoFromCamera,
      hostelPoliciesAccepted: hostelPoliciesAccepted,
      termsConditionsAccepted: termsConditionsAccepted,
    );
  }

  // ============================================================================
  // VALIDATION
  // ============================================================================

  static bool isCurrentStepValid(WidgetRef ref) {
    final current = ref.read(currentStepProvider);
    final model = ref.read(registrationProvider);

    switch (current) {
      case 0: // Personal Information
        return model.firstName.trim().isNotEmpty &&
            model.lastName.trim().isNotEmpty &&
            model.gender.trim().isNotEmpty &&
            model.email.trim().isNotEmpty &&
            _isValidEmail(model.email) &&
            model.phoneNumber.trim().isNotEmpty &&
            model.dateOfBirth != null;

      case 1: // Address Details
        if (model.sameAsCurrent) {
          return model.currentCountry.trim().isNotEmpty &&
              model.currentCity.trim().isNotEmpty &&
              model.currentAddress.trim().isNotEmpty;
        }
        return model.currentCountry.trim().isNotEmpty &&
            model.currentCity.trim().isNotEmpty &&
            model.currentAddress.trim().isNotEmpty &&
            model.permanentCountry.trim().isNotEmpty &&
            model.permanentCity.trim().isNotEmpty &&
            model.permanentAddress.trim().isNotEmpty;

      case 2: // Purpose of Stay
        if (model.purposeOfStay.isEmpty) return false;

        // Validate conditional fields based on purpose
        switch (model.purposeOfStay.toLowerCase()) {
          case 'student':
            return model.institutionName.trim().isNotEmpty &&
                model.courseDegree.trim().isNotEmpty;
          case 'business':
          case 'job':
            return model.jobBusinessDetails.trim().isNotEmpty &&
                model.businessStreetAddress.trim().isNotEmpty &&
                model.designation.trim().isNotEmpty;
          case 'other':
            return model.otherPurposeDetails.trim().isNotEmpty;
          default:
            return true;
        }

      case 3: // Identity Documents
        if (model.documentType.isEmpty || model.documentNumber.isEmpty) {
          return false;
        }
        if (model.documentType.toLowerCase() == 'cnic') {
          return model.documentImagePath != null &&
              model.documentBackImagePath != null;
        } else {
          return model.documentImagePath != null;
        }

      case 4: // Guardian Details
        return model.guardianName.trim().isNotEmpty &&
            model.guardianPhone.trim().isNotEmpty &&
            model.guardianRelation.trim().isNotEmpty;

      case 5: // Photo Verification & Terms
        return model.profileImagePath != null &&
            model.isFaceVerified &&
            model.hostelPoliciesAccepted &&
            model.termsConditionsAccepted;

      default:
        return false;
    }
  }

  static String? getCurrentStepValidationMessage(WidgetRef ref) {
    final current = ref.read(currentStepProvider);
    final model = ref.read(registrationProvider);

    switch (current) {
      case 0: // Personal Information
        if (model.firstName.trim().isEmpty) return 'First name is required';
        if (model.lastName.trim().isEmpty) return 'Last name is required';
        if (model.gender.trim().isEmpty) return 'Please select gender';
        if (model.email.trim().isEmpty) return 'Email is required';
        if (!_isValidEmail(model.email)) return 'Invalid email format';
        if (model.phoneNumber.trim().isEmpty) return 'Phone number is required';
        if (model.dateOfBirth == null) return 'Date of birth is required';
        return null;

      case 1: // Address Details
        if (model.currentCountry.trim().isEmpty)
          return 'Current country is required';
        if (model.currentCity.trim().isEmpty) return 'Current city is required';
        if (model.currentAddress.trim().isEmpty)
          return 'Current address is required';
        if (!model.sameAsCurrent) {
          if (model.permanentCountry.trim().isEmpty)
            return 'Permanent country is required';
          if (model.permanentCity.trim().isEmpty)
            return 'Permanent city is required';
          if (model.permanentAddress.trim().isEmpty)
            return 'Permanent address is required';
        }
        return null;

      case 2: // Purpose of Stay
        if (model.purposeOfStay.isEmpty) return 'Please select purpose of stay';

        switch (model.purposeOfStay.toLowerCase()) {
          case 'student':
            if (model.institutionName.trim().isEmpty)
              return 'Institution name is required';
            if (model.courseDegree.trim().isEmpty)
              return 'Course/Degree is required';
            break;
          case 'business':
          case 'job':
            if (model.jobBusinessDetails.trim().isEmpty)
              return 'Job/Business details are required';
            if (model.businessStreetAddress.trim().isEmpty)
              return 'Business address is required';
            if (model.designation.trim().isEmpty)
              return 'Designation is required';
            break;
          case 'other':
            if (model.otherPurposeDetails.trim().isEmpty)
              return 'Please specify purpose of stay';
            break;
        }
        return null;

      case 3: // Identity Documents
        if (model.documentType.isEmpty) return 'Please select document type';
        if (model.documentNumber.isEmpty) return 'Document number is required';
        if (model.documentType.toLowerCase() == 'cnic') {
          if (model.documentImagePath == null)
            return 'Please upload CNIC front image';
          if (model.documentBackImagePath == null)
            return 'Please upload CNIC back image';
        } else {
          if (model.documentImagePath == null)
            return 'Please upload passport image';
        }
        return null;

      case 4: // Guardian Details
        if (model.guardianName.trim().isEmpty)
          return 'Guardian name is required';
        if (model.guardianPhone.trim().isEmpty)
          return 'Guardian phone is required';
        if (model.guardianRelation.trim().isEmpty)
          return 'Guardian relation is required';
        return null;

      case 5: // Photo Verification & Terms
        if (model.profileImagePath == null)
          return 'Please capture or upload your photo';
        if (!model.isFaceVerified) return 'Face verification is required';
        if (!model.hostelPoliciesAccepted)
          return 'Please accept hostel policies';
        if (!model.termsConditionsAccepted)
          return 'Please accept terms & conditions';
        return null;

      default:
        return null;
    }
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  static bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
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
    print('   Purpose: ${model.purposeOfStay}');
    print('   Document: ${model.documentType} - ${model.documentNumber}');

    // TODO: Implement actual API call with TenantApi
    await Future.delayed(const Duration(seconds: 2));

    print('✅ REGISTRATION SUBMITTED SUCCESSFULLY');
  }
}
