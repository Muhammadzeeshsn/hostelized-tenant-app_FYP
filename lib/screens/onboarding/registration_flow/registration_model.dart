// lib/screens/onboarding/registration_flow/registration_model.dart

class RegistrationModel {
  // Step 1: Personal Information
  String firstName = '';
  String lastName = '';
  String gender = '';
  String email = '';
  String phoneNumber = '';
  DateTime? dateOfBirth;

  // Step 2: Address Details
  String currentCountry = '';
  String currentCity = '';
  String currentAddress = '';
  String permanentCountry = '';
  String permanentCity = '';
  String permanentAddress = '';
  bool sameAsCurrent = false;

  // Step 3: Purpose of Stay
  String purposeOfStay = ''; // student, business, tourist, other

  // Conditional fields for Student
  String institutionName = '';
  String courseDegree = '';
  String registrationNumber = '';

  // Conditional fields for Business/Job
  String jobBusinessDetails = '';
  String businessStreetAddress = '';
  String designation = '';

  // Conditional field for Other
  String otherPurposeDetails = '';

  // Step 4: Identity Documents
  String documentType = ''; // cnic, passport
  String documentNumber = '';
  String? documentImagePath; // Front/single image
  String? documentBackImagePath; // Back image for CNIC

  // Step 5: Guardian Details
  String guardianName = '';
  String guardianPhone = '';
  String guardianRelation = '';

  // Step 6: Photo Verification
  String? profileImagePath;
  String? faceEncodingData; // Store facial encoding as JSON string
  bool isFaceVerified = false;
  bool photoFromCamera = false; // Track if photo was taken from camera

  // Terms acceptance
  bool hostelPoliciesAccepted = false;
  bool termsConditionsAccepted = false;

  // CopyWith method for Riverpod state updates
  RegistrationModel copyWith({
    String? firstName,
    String? lastName,
    String? gender,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? currentCountry,
    String? currentCity,
    String? currentAddress,
    String? permanentCountry,
    String? permanentCity,
    String? permanentAddress,
    bool? sameAsCurrent,
    String? purposeOfStay,
    String? institutionName,
    String? courseDegree,
    String? registrationNumber,
    String? jobBusinessDetails,
    String? businessStreetAddress,
    String? designation,
    String? otherPurposeDetails,
    String? documentType,
    String? documentNumber,
    String? documentImagePath,
    String? documentBackImagePath,
    String? guardianName,
    String? guardianPhone,
    String? guardianRelation,
    String? profileImagePath,
    String? faceEncodingData,
    bool? isFaceVerified,
    bool? photoFromCamera,
    bool? hostelPoliciesAccepted,
    bool? termsConditionsAccepted,
  }) {
    return RegistrationModel()
      ..firstName = firstName ?? this.firstName
      ..lastName = lastName ?? this.lastName
      ..gender = gender ?? this.gender
      ..email = email ?? this.email
      ..phoneNumber = phoneNumber ?? this.phoneNumber
      ..dateOfBirth = dateOfBirth ?? this.dateOfBirth
      ..currentCountry = currentCountry ?? this.currentCountry
      ..currentCity = currentCity ?? this.currentCity
      ..currentAddress = currentAddress ?? this.currentAddress
      ..permanentCountry = permanentCountry ?? this.permanentCountry
      ..permanentCity = permanentCity ?? this.permanentCity
      ..permanentAddress = permanentAddress ?? this.permanentAddress
      ..sameAsCurrent = sameAsCurrent ?? this.sameAsCurrent
      ..purposeOfStay = purposeOfStay ?? this.purposeOfStay
      ..institutionName = institutionName ?? this.institutionName
      ..courseDegree = courseDegree ?? this.courseDegree
      ..registrationNumber = registrationNumber ?? this.registrationNumber
      ..jobBusinessDetails = jobBusinessDetails ?? this.jobBusinessDetails
      ..businessStreetAddress =
          businessStreetAddress ?? this.businessStreetAddress
      ..designation = designation ?? this.designation
      ..otherPurposeDetails = otherPurposeDetails ?? this.otherPurposeDetails
      ..documentType = documentType ?? this.documentType
      ..documentNumber = documentNumber ?? this.documentNumber
      ..documentImagePath = documentImagePath ?? this.documentImagePath
      ..documentBackImagePath =
          documentBackImagePath ?? this.documentBackImagePath
      ..guardianName = guardianName ?? this.guardianName
      ..guardianPhone = guardianPhone ?? this.guardianPhone
      ..guardianRelation = guardianRelation ?? this.guardianRelation
      ..profileImagePath = profileImagePath ?? this.profileImagePath
      ..faceEncodingData = faceEncodingData ?? this.faceEncodingData
      ..isFaceVerified = isFaceVerified ?? this.isFaceVerified
      ..photoFromCamera = photoFromCamera ?? this.photoFromCamera
      ..hostelPoliciesAccepted =
          hostelPoliciesAccepted ?? this.hostelPoliciesAccepted
      ..termsConditionsAccepted =
          termsConditionsAccepted ?? this.termsConditionsAccepted;
  }
}
