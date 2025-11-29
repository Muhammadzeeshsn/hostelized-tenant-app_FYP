// lib/auth/auth_repo.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/tenant_api.dart';

class AuthRepo {
  AuthRepo(this._storage, this._api);

  final FlutterSecureStorage _storage;
  final TenantApi _api;

  /// Send OTP for the given tenant username.
  /// Returns a map with optional `contactMasked` if successful, or null on error.
  Future<Map<String, String>?> sendOtpForUsername(String username) async {
    try {
      final res = await _api.loginByUsername(username);
      final masked = (res['contactMasked'] ?? '') as String;
      if (kDebugMode) {
        debugPrint(
          'sendOtpForUsername OK username=$username maskedContact=$masked',
        );
      }
      return {'username': username, 'contactMasked': masked};
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('sendOtpForUsername ERROR: $e\n$st');
      }
      return null;
    }
  }

  /// Verify tenant OTP and persist tokens.
  Future<bool> verifyTenantOtp(String username, String code) async {
    try {
      final res = await _api.verifyTenantOtp(username, code);
      final access = res['accessToken'] as String?;
      final refresh = res['refreshToken'] as String?;

      if (access != null) {
        await _storage.write(key: 'accessToken', value: access);
      }
      if (refresh != null) {
        await _storage.write(key: 'refreshToken', value: refresh);
      }

      if (kDebugMode) {
        debugPrint('verifyTenantOtp OK username=$username');
      }
      return true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('verifyTenantOtp ERROR username=$username: $e\n$st');
      }
      return false;
    }
  }

  /// Lookup tenant username from email or phone.
  Future<String?> lookupUsername(String emailOrPhone) async {
    try {
      final username = await _api.lookupTenantUsername(emailOrPhone);
      if (kDebugMode) {
        debugPrint(
          'lookupUsername OK emailOrPhone=$emailOrPhone username=$username',
        );
      }
      return username;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('lookupUsername ERROR emailOrPhone=$emailOrPhone: $e\n$st');
      }
      return null;
    }
  }

  /// Simple helper to clear tokens (manual logout).
  Future<void> clearSession() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }
}
