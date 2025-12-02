// lib/models/tenant_registration_draft.dart

/// Supported gender values.
enum Gender { male, female, other }

/// Supported “purpose of stay” categories.
enum PurposeOfStay { student, jobBusiness, other }

/// Supported identity document types.
enum DocumentType { cnic, passport }

/// Local draft of the tenant registration flow.
///
/// This is only stored locally (SharedPreferences) until the user
/// completes registration and we submit to the backend.
class TenantRegistrationDraft {
  // Basic info
  final String? firstName;
  final String? lastName;
  final Gender? gender;
  final PurposeOfStay? purposeOfStay;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;

  // Identity / address
  final DocumentType? documentType;
  final String? cnicNumber;
  final String? address;
  final String? country;
  final String? province;
  final String? cnicFrontPath;
  final String? cnicBackPath;
  final String? passportImagePath;

  // Guardian / emergency contact
  final String? guardianRelationship;
  final String? guardianName;
  final String? guardianPhone;

  // Student details
  final String? studentCollege;
  final String? studentDepartment;
  final String? studentRegNo;

  // Job / business details
  final String? businessDetails;
  final String? businessAddress;
  final String? businessDesignation;

  // “Other” reason
  final String? otherPurpose;

  // Face / profile
  final String? profilePhotoPath;
  final bool hasFaceScan;
  final String? faceScanId;

  const TenantRegistrationDraft({
    this.firstName,
    this.lastName,
    this.gender,
    this.purposeOfStay,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.documentType,
    this.cnicNumber,
    this.address,
    this.country,
    this.province,
    this.cnicFrontPath,
    this.cnicBackPath,
    this.passportImagePath,
    this.guardianRelationship,
    this.guardianName,
    this.guardianPhone,
    this.studentCollege,
    this.studentDepartment,
    this.studentRegNo,
    this.businessDetails,
    this.businessAddress,
    this.businessDesignation,
    this.otherPurpose,
    this.profilePhotoPath,
    this.hasFaceScan = false,
    this.faceScanId,
  });

  /// Empty initial draft.
  const TenantRegistrationDraft.empty() : this();

  TenantRegistrationDraft copyWith({
    String? firstName,
    String? lastName,
    Gender? gender,
    PurposeOfStay? purposeOfStay,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    DocumentType? documentType,
    String? cnicNumber,
    String? address,
    String? country,
    String? province,
    String? cnicFrontPath,
    String? cnicBackPath,
    String? passportImagePath,
    String? guardianRelationship,
    String? guardianName,
    String? guardianPhone,
    String? studentCollege,
    String? studentDepartment,
    String? studentRegNo,
    String? businessDetails,
    String? businessAddress,
    String? businessDesignation,
    String? otherPurpose,
    String? profilePhotoPath,
    bool? hasFaceScan,
    String? faceScanId,
  }) {
    return TenantRegistrationDraft(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      purposeOfStay: purposeOfStay ?? this.purposeOfStay,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      documentType: documentType ?? this.documentType,
      cnicNumber: cnicNumber ?? this.cnicNumber,
      address: address ?? this.address,
      country: country ?? this.country,
      province: province ?? this.province,
      cnicFrontPath: cnicFrontPath ?? this.cnicFrontPath,
      cnicBackPath: cnicBackPath ?? this.cnicBackPath,
      passportImagePath: passportImagePath ?? this.passportImagePath,
      guardianRelationship: guardianRelationship ?? this.guardianRelationship,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      studentCollege: studentCollege ?? this.studentCollege,
      studentDepartment: studentDepartment ?? this.studentDepartment,
      studentRegNo: studentRegNo ?? this.studentRegNo,
      businessDetails: businessDetails ?? this.businessDetails,
      businessAddress: businessAddress ?? this.businessAddress,
      businessDesignation: businessDesignation ?? this.businessDesignation,
      otherPurpose: otherPurpose ?? this.otherPurpose,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      hasFaceScan: hasFaceScan ?? this.hasFaceScan,
      faceScanId: faceScanId ?? this.faceScanId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender?.name,
      'purposeOfStay': purposeOfStay?.name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'documentType': documentType?.name,
      'cnicNumber': cnicNumber,
      'address': address,
      'country': country,
      'province': province,
      'cnicFrontPath': cnicFrontPath,
      'cnicBackPath': cnicBackPath,
      'passportImagePath': passportImagePath,
      'guardianRelationship': guardianRelationship,
      'guardianName': guardianName,
      'guardianPhone': guardianPhone,
      'studentCollege': studentCollege,
      'studentDepartment': studentDepartment,
      'studentRegNo': studentRegNo,
      'businessDetails': businessDetails,
      'businessAddress': businessAddress,
      'businessDesignation': businessDesignation,
      'otherPurpose': otherPurpose,
      'profilePhotoPath': profilePhotoPath,
      'hasFaceScan': hasFaceScan,
      'faceScanId': faceScanId,
    };
  }

  factory TenantRegistrationDraft.fromJson(Map<String, dynamic> json) {
    Gender? _gender;
    if (json['gender'] is String) {
      final g = json['gender'] as String;
      _gender = Gender.values.cast<Gender?>().firstWhere(
            (e) => e!.name == g,
            orElse: () => null,
          );
    }

    PurposeOfStay? _purpose;
    if (json['purposeOfStay'] is String) {
      final p = json['purposeOfStay'] as String;
      _purpose = PurposeOfStay.values.cast<PurposeOfStay?>().firstWhere(
            (e) => e!.name == p,
            orElse: () => null,
          );
    }

    DocumentType? _docType;
    if (json['documentType'] is String) {
      final d = json['documentType'] as String;
      _docType = DocumentType.values.cast<DocumentType?>().firstWhere(
            (e) => e!.name == d,
            orElse: () => null,
          );
    }

    DateTime? dob;
    if (json['dateOfBirth'] is String) {
      try {
        dob = DateTime.parse(json['dateOfBirth'] as String);
      } catch (_) {}
    }

    return TenantRegistrationDraft(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      gender: _gender,
      purposeOfStay: _purpose,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: dob,
      documentType: _docType,
      cnicNumber: json['cnicNumber'] as String?,
      address: json['address'] as String?,
      country: json['country'] as String?,
      province: json['province'] as String?,
      cnicFrontPath: json['cnicFrontPath'] as String?,
      cnicBackPath: json['cnicBackPath'] as String?,
      passportImagePath: json['passportImagePath'] as String?,
      guardianRelationship: json['guardianRelationship'] as String?,
      guardianName: json['guardianName'] as String?,
      guardianPhone: json['guardianPhone'] as String?,
      studentCollege: json['studentCollege'] as String?,
      studentDepartment: json['studentDepartment'] as String?,
      studentRegNo: json['studentRegNo'] as String?,
      businessDetails: json['businessDetails'] as String?,
      businessAddress: json['businessAddress'] as String?,
      businessDesignation: json['businessDesignation'] as String?,
      otherPurpose: json['otherPurpose'] as String?,
      profilePhotoPath: json['profilePhotoPath'] as String?,
      hasFaceScan: (json['hasFaceScan'] as bool?) ?? false,
      faceScanId: json['faceScanId'] as String?,
    );
  }
}
