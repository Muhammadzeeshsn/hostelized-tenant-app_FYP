// lib/auth/auth_repo.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/tenant_api.dart';

class AuthRepo {
  AuthRepo(this._storage, this._api);

  final FlutterSecureStorage _storage;
  final TenantApi _api;

  /// Send OTP to tenant using username/email/phone.
  Future<bool> sendOtpForUsername(String identifier) async {
    try {
      debugPrint('AuthRepo.sendOtpForUsername identifier=$identifier');
      await _api.loginByUsername(identifier);
      debugPrint('AuthRepo.sendOtpForUsername OK');
      return true;
    } catch (e, st) {
      debugPrint('AuthRepo.sendOtpForUsername ERROR: $e\n$st');
      return false;
    }
  }

  /// Verify tenant OTP and persist tokens.
  Future<bool> verifyTenantOtp(String identifier, String otp) async {
    try {
      debugPrint(
        'AuthRepo.verifyTenantOtp identifier=$identifier otp=<hidden>',
      );
      final tokens = await _api.verifyTenantOtp(identifier, otp);

      final access = tokens['accessToken'] as String?;
      final refresh = tokens['refreshToken'] as String?;

      debugPrint(
        'AuthRepo.verifyTenantOtp tokens accessPresent=${access != null} refreshPresent=${refresh != null}',
      );

      if (access == null || refresh == null) {
        return false;
      }

      await _storage.write(key: 'accessToken', value: access);
      await _storage.write(key: 'refreshToken', value: refresh);
      debugPrint('AuthRepo.verifyTenantOtp tokens persisted to storage');
      return true;
    } catch (e, st) {
      debugPrint('AuthRepo.verifyTenantOtp ERROR: $e\n$st');
      return false;
    }
  }

  /// Lookup tenant username via email or phone.
  Future<String?> lookupUsername(String emailOrPhone) async {
    try {
      debugPrint('AuthRepo.lookupUsername emailOrPhone=$emailOrPhone');
      final res = await _api.lookupTenantUsername(emailOrPhone);
      final username = res['username'] as String?;
      debugPrint('AuthRepo.lookupUsername OK username=$username');
      return username;
    } catch (e, st) {
      debugPrint('AuthRepo.lookupUsername ERROR: $e\n$st');
      rethrow;
    }
  }
}
