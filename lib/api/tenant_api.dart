// lib/api/tenant_api.dart

import 'package:flutter/foundation.dart';
import 'dio_client.dart';

class TenantApi {
  final _dio = DioClient.I.dio;

  // ---------------------------------------------------------------------------
  // Auth (Tenant username/email/phone -> OTP)
  // ---------------------------------------------------------------------------

  Future<void> loginByUsername(String identifier) async {
    debugPrint('TenantApi.loginByUsername identifier=$identifier');
    final r = await _dio.post(
      '/auth/tenant/login-username',
      data: {'identifier': identifier},
    );
    debugPrint(
      'TenantApi.loginByUsername response status=${r.statusCode} data=${r.data}',
    );
  }

  Future<Map<String, dynamic>> verifyTenantOtp(
    String identifier,
    String otp,
  ) async {
    debugPrint('TenantApi.verifyTenantOtp identifier=$identifier otp=<hidden>');
    final r = await _dio.post(
      '/auth/tenant/verify-otp',
      data: {'identifier': identifier, 'otp': otp},
    );
    debugPrint(
      'TenantApi.verifyTenantOtp response status=${r.statusCode} data=${r.data}',
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> lookupTenantUsername(String emailOrPhone) async {
    debugPrint('TenantApi.lookupTenantUsername emailOrPhone=$emailOrPhone');
    final r = await _dio.post(
      '/auth/lookup-username',
      data: {'emailOrPhone': emailOrPhone},
    );
    debugPrint(
      'TenantApi.lookupTenantUsername response status=${r.statusCode} data=${r.data}',
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ---------------------------------------------------------------------------
  // Home
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getHome() async {
    final r = await _dio.get(
      '/tenant/home',
      queryParameters: {'includeNotices': '1'},
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ---------------------------------------------------------------------------
  // Invoices
  // ---------------------------------------------------------------------------

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

  Future<Map<String, dynamic>> getInvoice(String id) async {
    final r = await _dio.get('/tenant/invoices/$id');
    return Map<String, dynamic>.from(r.data as Map);
  }

  // Placeholder checkout (backend already returns a URL string)
  Future<String> initiateCheckout(String invoiceId) async {
    final r = await _dio.post(
      '/tenant/payments/checkout',
      data: {'invoiceId': invoiceId, 'method': 'ONLINE'},
    );
    return (r.data as Map)['checkoutUrl'] as String;
  }

  // ---------------------------------------------------------------------------
  // Payments / receipts
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Tickets
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Notices
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Room / Hostel / Profile
  // ---------------------------------------------------------------------------

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
}
