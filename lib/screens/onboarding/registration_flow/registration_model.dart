// lib/screens/onboarding/registration_flow/registration_model.dart

class RegistrationModel {
  // Personal Info
  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';
  DateTime? dateOfBirth;
  String gender = '';

  // Contact Details
  String personalEmail = '';
  String emergencyPhone = '';
  String alternatePhone = '';

  // Address
  String currentAddress = '';
  String permanentAddress = '';
  String city = '';
  String state = '';
  String country = '';
  String postalCode = '';

  // Job Details
  String employmentStatus = '';
  String companyName = '';
  String jobTitle = '';
  String workEmail = '';
  String workPhone = '';
  String monthlyIncome = '';

  // Study Details - Updated to match actual fields
  bool isStudent = false;
  String institutionName = '';
  String courseName = '';
  String studentId = '';
  String yearOfStudy = '';

  // Emergency Contacts
  List<Map<String, String>> emergencyContacts = [];

  // Agreements
  bool termsAccepted = false;
  bool privacyAccepted = false;

  // Profile Picture
  String? profileImagePath;

  // CopyWith method for Riverpod
  RegistrationModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? personalEmail,
    String? emergencyPhone,
    String? alternatePhone,
    String? currentAddress,
    String? permanentAddress,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? employmentStatus,
    String? companyName,
    String? jobTitle,
    String? workEmail,
    String? workPhone,
    String? monthlyIncome,
    bool? isStudent,
    String? institutionName,
    String? courseName,
    String? studentId,
    String? yearOfStudy,
    List<Map<String, String>>? emergencyContacts,
    bool? termsAccepted,
    bool? privacyAccepted,
    String? profileImagePath,
  }) {
    return RegistrationModel()
      ..firstName = firstName ?? this.firstName
      ..lastName = lastName ?? this.lastName
      ..email = email ?? this.email
      ..phoneNumber = phoneNumber ?? this.phoneNumber
      ..dateOfBirth = dateOfBirth ?? this.dateOfBirth
      ..gender = gender ?? this.gender
      ..personalEmail = personalEmail ?? this.personalEmail
      ..emergencyPhone = emergencyPhone ?? this.emergencyPhone
      ..alternatePhone = alternatePhone ?? this.alternatePhone
      ..currentAddress = currentAddress ?? this.currentAddress
      ..permanentAddress = permanentAddress ?? this.permanentAddress
      ..city = city ?? this.city
      ..state = state ?? this.state
      ..country = country ?? this.country
      ..postalCode = postalCode ?? this.postalCode
      ..employmentStatus = employmentStatus ?? this.employmentStatus
      ..companyName = companyName ?? this.companyName
      ..jobTitle = jobTitle ?? this.jobTitle
      ..workEmail = workEmail ?? this.workEmail
      ..workPhone = workPhone ?? this.workPhone
      ..monthlyIncome = monthlyIncome ?? this.monthlyIncome
      ..isStudent = isStudent ?? this.isStudent
      ..institutionName = institutionName ?? this.institutionName
      ..courseName = courseName ?? this.courseName
      ..studentId = studentId ?? this.studentId
      ..yearOfStudy = yearOfStudy ?? this.yearOfStudy
      ..emergencyContacts = emergencyContacts ?? this.emergencyContacts
      ..termsAccepted = termsAccepted ?? this.termsAccepted
      ..privacyAccepted = privacyAccepted ?? this.privacyAccepted
      ..profileImagePath = profileImagePath ?? this.profileImagePath;
  }
}
