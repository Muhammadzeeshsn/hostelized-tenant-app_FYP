// lib/api/tenant_api.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/tenant_registration_draft.dart';
import 'dio_client.dart';

class TenantApi {
  final _dio = DioClient.I.dio;

  // ===========================================================================
  // AUTHENTICATION (Username Only)
  // ===========================================================================

  /// Send OTP to username only - no email/phone support
  Future<void> loginByUsername(String username) async {
    debugPrint('[AUTH] loginByUsername: $username');

    try {
      final r = await _dio.post(
        '/auth/tenant/login-username',
        data: {'username': username}, // Backend expects 'username' field
      );
      debugPrint('[AUTH] OTP Sent. Status: ${r.statusCode}');

      if (r.statusCode != 200 && r.statusCode != 204) {
        throw Exception('Failed to send OTP: ${r.data}');
      }
    } on DioException catch (e) {
      debugPrint('[AUTH] OTP Send Error: ${e.message}');
      throw Exception(_parseAuthError(e));
    }
  }

  /// Verify OTP for username - returns token on success
  Future<Map<String, dynamic>> verifyTenantOtp(
    String username,
    String otp,
  ) async {
    debugPrint('[AUTH] verifyTenantOtp for: $username');

    try {
      final r = await _dio.post(
        '/auth/tenant/verify-otp',
        data: {
          'username': username, // Backend expects 'username' field
          'otp': otp,
        },
      );

      debugPrint('[AUTH] OTP Verify Response: ${r.statusCode}');

      if (r.statusCode == 200) {
        final data = Map<String, dynamic>.from(r.data as Map);
        // Expected: { "success": true, "token": "abc123" }
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Invalid OTP');
        }
        return data;
      }

      throw Exception('OTP verification failed: ${r.statusCode}');
    } on DioException catch (e) {
      debugPrint('[AUTH] OTP Verify Error: ${e.message}');
      throw Exception(_parseAuthError(e));
    }
  }

  /// Lookup username by email or phone (for forgot username)
  Future<Map<String, dynamic>> lookupTenantUsername(String contact) async {
    debugPrint('[AUTH] lookupUsername for contact: $contact');

    try {
      final r = await _dio.post(
        '/auth/lookup-username',
        data: {'contact': contact}, // Backend handles email/phone lookup
      );

      if (r.statusCode == 200) {
        return Map<String, dynamic>.from(r.data as Map);
        // Expected: { "username": "user123", "success": true }
      }

      throw Exception('Lookup failed: ${r.statusCode}');
    } on DioException catch (e) {
      debugPrint('[AUTH] Lookup Error: ${e.message}');
      throw Exception(_parseAuthError(e));
    }
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Parse Dio errors to user-friendly messages
  String _parseAuthError(DioException e) {
    if (e.response?.data != null) {
      try {
        final data = e.response!.data as Map;
        return data['message'] ?? 'Authentication failed';
      } catch (_) {
        return 'Server error: ${e.response?.statusCode}';
      }
    }
    return 'Network error. Please check your connection.';
  }

  // ===========================================================================
  // EXISTING METHODS (UNCHANGED)
  // ===========================================================================

  Future<Map<String, dynamic>> getHome() async {
    final r = await _dio.get(
      '/tenant/home',
      queryParameters: {'includeNotices': '1'},
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> listInvoices({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final r = await _dio.get(
      '/tenant/invoices',
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<String> initiateCheckout(String invoiceId) async {
    final r = await _dio.post(
      '/tenant/payments/checkout',
      data: {'invoiceId': invoiceId, 'method': 'ONLINE'},
    );
    return (r.data as Map)['checkoutUrl'] as String;
  }

  Future<Map<String, dynamic>> listPayments({
    int page = 1,
    int pageSize = 20,
  }) async {
    final r = await _dio.get(
      '/tenant/payments',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> createTicket({
    required String subject,
    required String message,
    String? category,
  }) async {
    final r = await _dio.post(
      '/tenant/tickets',
      data: {
        'subject': subject,
        'message': message,
        if (category != null) 'category': category,
      },
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> listTickets({
    int page = 1,
    int pageSize = 20,
  }) async {
    final r = await _dio.get(
      '/tenant/tickets',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> listNotices({
    int page = 1,
    int pageSize = 20,
  }) async {
    final r = await _dio.get(
      '/tenant/notices',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<void> markNoticeRead(String id) async {
    await _dio.patch('/tenant/notices/$id/read');
  }

  Future<Map<String, dynamic>?> getRoom() async {
    final r = await _dio.get('/tenant/room');
    if (r.data == null) return null;
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>?> getHostel() async {
    final r = await _dio.get('/tenant/hostel');
    if (r.data == null) return null;
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final r = await _dio.get('/tenant/profile');
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> updateProfile({
    String? phone,
    String? avatarUrl,
  }) async {
    final r = await _dio.patch(
      '/tenant/profile',
      data: {'phone': phone, 'avatarUrl': avatarUrl},
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ===========================================================================
  // REGISTRATION
  // ===========================================================================

  /// Submit complete tenant registration with file uploads
  Future<bool> submitTenantRegistration(TenantRegistrationDraft draft) async {
    debugPrint('[REGISTRATION] submitTenantRegistration for: ${draft.email}');

    try {
      final formData = await _draftToFormData(draft);
      final r = await _dio.post(
        '/tenant/register',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      debugPrint('[REGISTRATION] Response: ${r.statusCode}');
      return r.statusCode == 201 || r.statusCode == 200;
    } catch (e) {
      debugPrint('[REGISTRATION] Error: $e');
      rethrow;
    }
  }

  /// Convert draft to multipart form data
  Future<FormData> _draftToFormData(TenantRegistrationDraft draft) async {
    final formData = FormData();

    // Add text fields
    final fields = {
      'firstName': draft.firstName ?? '',
      'lastName': draft.lastName ?? '',
      'email': draft.email ?? '',
      'phone': draft.phone ?? '',
      'gender': draft.gender?.name ?? '',
      'purposeOfStay': draft.purposeOfStay?.name ?? '',
      'address': draft.address ?? '',
      'country': draft.country ?? '',
      'province': draft.province ?? '',
      'cnicNumber': draft.cnicNumber ?? '',
      'documentType': draft.documentType?.name ?? '',
      'guardianRelationship': draft.guardianRelationship ?? '',
      'guardianName': draft.guardianName ?? '',
      'guardianPhone': draft.guardianPhone ?? '',
      'studentCollege': draft.studentCollege ?? '',
      'studentDepartment': draft.studentDepartment ?? '',
      'studentRegNo': draft.studentRegNo ?? '',
      'businessDetails': draft.businessDetails ?? '',
      'businessAddress': draft.businessAddress ?? '',
      'businessDesignation': draft.businessDesignation ?? '',
      'otherPurpose': draft.otherPurpose ?? '',
      'faceScanId': draft.faceScanId ?? '',
      'hasFaceScan': draft.hasFaceScan.toString(),
    };

    fields.forEach((key, value) {
      formData.fields.add(MapEntry(key, value));
    });

    // Add file fields
    Future<void> addFile(String fieldName, String? path) async {
      if (path != null && File(path).existsSync()) {
        formData.files.add(
          MapEntry(fieldName, await MultipartFile.fromFile(path)),
        );
      }
    }

    await addFile('profilePhoto', draft.profilePhotoPath);
    await addFile('cnicFront', draft.cnicFrontPath);
    await addFile('cnicBack', draft.cnicBackPath);
    await addFile('passportImage', draft.passportImagePath);

    return formData;
  }
}
