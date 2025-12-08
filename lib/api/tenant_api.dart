// lib/api/tenant_api.dart (Updated methods)

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/tenant_registration_draft.dart';
import 'dio_client.dart';

class TenantApi {
  final DioClient _client = DioClient.I;

  // ===========================================================================
  // AUTHENTICATION - USE PUBLIC DIO
  // ===========================================================================

  /// Send OTP to username / email / phone
  Future<void> loginByUsername(String identifier) async {
    debugPrint('[AUTH] loginByUsername: $identifier');

    try {
      // Use publicDio for auth endpoints
      final r = await _client.publicDio.post(
        '/auth/tenant/login-username',
        data: {'identifier': identifier},
      );

      debugPrint(
        '[AUTH] loginByUsername status: ${r.statusCode}, data: ${r.data}',
      );

      if (r.statusCode == 200 || r.statusCode == 201 || r.statusCode == 204) {
        return;
      }

      throw Exception('Login failed: ${r.statusCode}');
    } on DioException catch (e) {
      debugPrint('[AUTH] loginByUsername DioError: ${e.type} - ${e.message}');

      if (e.response != null) {
        final status = e.response?.statusCode;
        final data = e.response?.data;

        String msg = 'Login failed';
        if (data is Map) {
          msg = data['message'] ?? data['error'] ?? msg;
        }

        if (status == 401 || status == 404) {
          throw Exception('Username not found. Please check and try again.');
        }
        if (status == 400) {
          throw Exception('Invalid username. Please check and try again.');
        }
        if (status == 500) {
          throw Exception('Server error. Please try again later.');
        }

        throw Exception(msg);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timed out. Please check your connection.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Network error. Please check your internet connection.');
      }

      throw Exception('Network error: ${e.message}');
    }
  }

  /// Verify tenant OTP
  Future<Map<String, dynamic>> verifyTenantOtp(
    String identifier,
    String otp,
  ) async {
    debugPrint('[AUTH] verifyTenantOtp for: $identifier');

    try {
      // Use publicDio for auth endpoints
      final r = await _client.publicDio.post(
        '/auth/tenant/verify-otp',
        data: {'identifier': identifier, 'otp': otp},
      );

      debugPrint(
        '[AUTH] verifyTenantOtp status: ${r.statusCode}, data: ${r.data}',
      );

      if (r.statusCode == 200 || r.statusCode == 201) {
        return Map<String, dynamic>.from(r.data as Map);
      }

      throw Exception('OTP verification failed: ${r.statusCode}');
    } on DioException catch (e) {
      debugPrint('[AUTH] verifyTenantOtp DioError: ${e.type} - ${e.message}');

      if (e.response != null) {
        final status = e.response?.statusCode;
        final data = e.response?.data;

        String msg = 'OTP verification failed';
        if (data is Map) {
          msg = data['message'] ?? data['error'] ?? msg;
        }

        if (status == 400 || status == 401) {
          throw Exception('Invalid OTP');
        }
        if (status == 404) {
          throw Exception('Username not found. Please check and try again.');
        }
        if (status == 500) {
          throw Exception('Server error. Please try again later.');
        }

        throw Exception(msg);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('OTP verification timed out. Please try again.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Network error. Please check your internet connection.');
      }

      throw Exception('Network error: ${e.message}');
    }
  }

  /// Lookup username by email or phone
  Future<Map<String, dynamic>> lookupTenantUsername(String contact) async {
    debugPrint('[AUTH] lookupUsername for contact: $contact');

    try {
      // Use publicDio for auth endpoints
      final r = await _client.publicDio.post(
        '/auth/lookup-username',
        data: {'emailOrPhone': contact},
      );

      debugPrint(
        '[AUTH] lookupUsername status: ${r.statusCode}, data: ${r.data}',
      );

      if (r.statusCode == 200 || r.statusCode == 201) {
        return Map<String, dynamic>.from(r.data as Map);
      }

      throw Exception('Lookup failed: ${r.statusCode}');
    } on DioException catch (e) {
      debugPrint('[AUTH] Lookup DioError: ${e.type} - ${e.message}');

      if (e.response != null) {
        final status = e.response?.statusCode;
        final data = e.response?.data;

        String msg = 'Lookup failed';
        if (data is Map) {
          msg = data['message'] ?? data['error'] ?? msg;
        }

        if (status == 404) {
          throw Exception('No username found for this contact');
        }
        if (status == 400) {
          throw Exception('Email or phone is required');
        }
        if (status == 401) {
          // This shouldn't happen with publicDio, but just in case
          throw Exception('Please try again');
        }

        throw Exception(msg);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timed out. Please check your connection.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Network error. Please check your connection.');
      }

      throw Exception('Network error: ${e.message}');
    }
  }

  // ===========================================================================
  // PROFILE COMPLETION CHECK
  // ===========================================================================

  /// Check if user has complete profile
  Future<bool> hasCompleteProfile() async {
    try {
      // Use authenticated dio
      final r = await _client.dio.get('/tenant/profile');
      final data = Map<String, dynamic>.from(r.data as Map);

      // Check for required profile fields
      final requiredFields = ['firstName', 'lastName', 'phone', 'address'];
      bool hasAllFields = requiredFields.every((field) {
        final value = data[field];
        return value != null && value.toString().trim().isNotEmpty;
      });

      // Check if profile photo exists
      final hasProfilePhoto =
          data['avatarUrl'] != null && (data['avatarUrl'] as String).isNotEmpty;

      return hasAllFields && hasProfilePhoto;
    } catch (e) {
      debugPrint('[AUTH] Profile check failed: $e');
      return false;
    }
  }

  // ===========================================================================
  // HOME & DASHBOARD - USE AUTHENTICATED DIO
  // ===========================================================================

  Future<Map<String, dynamic>> getHome() async {
    final r = await _client.dio.get(
      '/tenant/home',
      queryParameters: {'includeNotices': '1'},
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ===========================================================================
  // INVOICES & PAYMENTS
  // ===========================================================================

  Future<Map<String, dynamic>> listInvoices({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final r = await _client.dio.get(
      '/tenant/invoices',
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> getInvoice(String id) async {
    final r = await _client.dio.get('/tenant/invoices/$id');
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<String> initiateCheckout(String invoiceId) async {
    final r = await _client.dio.post(
      '/tenant/payments/checkout',
      data: {'invoiceId': invoiceId, 'method': 'ONLINE'},
    );
    return (r.data as Map)['checkoutUrl'] as String;
  }

  Future<Map<String, dynamic>> listPayments({
    int page = 1,
    int pageSize = 20,
  }) async {
    final r = await _client.dio.get(
      '/tenant/payments',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ===========================================================================
  // TICKETS & SUPPORT
  // ===========================================================================

  Future<Map<String, dynamic>> createTicket({
    required String subject,
    required String message,
    String? category,
  }) async {
    final r = await _client.dio.post(
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
    final r = await _client.dio.get(
      '/tenant/tickets',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ===========================================================================
  // NOTICES & ANNOUNCEMENTS
  // ===========================================================================

  Future<Map<String, dynamic>> listNotices({
    int page = 1,
    int pageSize = 20,
  }) async {
    final r = await _client.dio.get(
      '/tenant/notices',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<void> markNoticeRead(String id) async {
    await _client.dio.patch('/tenant/notices/$id/read');
  }

  // ===========================================================================
  // PROFILE & HOSTEL INFO
  // ===========================================================================

  Future<Map<String, dynamic>?> getRoom() async {
    final r = await _client.dio.get('/tenant/room');
    if (r.data == null) return null;
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>?> getHostel() async {
    final r = await _client.dio.get('/tenant/hostel');
    if (r.data == null) return null;
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final r = await _client.dio.get('/tenant/profile');
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> updateProfile({
    String? phone,
    String? avatarUrl,
  }) async {
    final r = await _client.dio.patch(
      '/tenant/profile',
      data: {'phone': phone, 'avatarUrl': avatarUrl},
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ===========================================================================
  // REGISTRATION
  // ===========================================================================

  Future<bool> submitTenantRegistration(TenantRegistrationDraft draft) async {
    debugPrint('[REGISTRATION] submitTenantRegistration for: ${draft.email}');

    try {
      final formData = await _draftToFormData(draft);
      final r = await _client.dio.post(
        '/tenant/register',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      debugPrint('[REGISTRATION] Response: ${r.statusCode} - ${r.data}');
      return r.statusCode == 201 || r.statusCode == 200;
    } catch (e) {
      debugPrint('[REGISTRATION] Error: $e');
      rethrow;
    }
  }

  Future<FormData> _draftToFormData(TenantRegistrationDraft draft) async {
    final formData = FormData();

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
