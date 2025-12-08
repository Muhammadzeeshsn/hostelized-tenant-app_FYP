// lib/auth/auth_repo.dart (Updated with retry limiting)

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../api/tenant_api.dart';

/// Repository for tenant authentication and registration
class AuthRepo {
  final FlutterSecureStorage _storage;
  final TenantApi _api;

  // Retry limiting
  final Map<String, int> _failedAttempts = {};
  final Map<String, DateTime> _lastFailedTime = {};
  static const int maxAttempts = 3;
  static const Duration cooldownPeriod = Duration(minutes: 15);

  static const String _keyToken = 'auth_token';
  static const String _keyUsername = 'username';
  static const String _keyIsRegistered = 'is_registered';

  AuthRepo(this._storage, this._api);

  // ===========================================================================
  // RETRY LIMITING
  // ===========================================================================

  bool _canRetry(String endpoint) {
    final attempts = _failedAttempts[endpoint] ?? 0;
    final lastFailed = _lastFailedTime[endpoint];

    if (attempts >= maxAttempts && lastFailed != null) {
      final cooldownEnd = lastFailed.add(cooldownPeriod);
      if (DateTime.now().isBefore(cooldownEnd)) {
        return false;
      }
      // Cooldown expired, reset attempts
      _failedAttempts[endpoint] = 0;
    }

    return attempts < maxAttempts;
  }

  void _recordFailure(String endpoint) {
    _failedAttempts[endpoint] = (_failedAttempts[endpoint] ?? 0) + 1;
    _lastFailedTime[endpoint] = DateTime.now();
  }

  void _resetFailures(String endpoint) {
    _failedAttempts.remove(endpoint);
    _lastFailedTime.remove(endpoint);
  }

  // ===========================================================================
  // AUTHENTICATION
  // ===========================================================================

  Future<void> sendOtpForUsername(String identifier) async {
    final trimmed = identifier.trim();
    if (trimmed.isEmpty) {
      throw Exception('Username is required');
    }

    const endpoint = 'send-otp';
    if (!_canRetry(endpoint)) {
      throw Exception(
          'Too many failed attempts. Please try again in 15 minutes.');
    }

    try {
      debugPrint('[AuthRepo][LOGIN] Sending OTP for: $trimmed');
      await _api.loginByUsername(trimmed);
      debugPrint('[AuthRepo][LOGIN] OTP send call completed');

      // Reset failures on success
      _resetFailures(endpoint);
    } on DioException catch (e) {
      debugPrint('[AuthRepo][LOGIN] Dio Error: ${e.message}');
      _recordFailure(endpoint);
      throw Exception('Login failed. Please check your details.');
    } catch (e) {
      debugPrint('[AuthRepo][LOGIN] Error sending OTP: $e');
      _recordFailure(endpoint);
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> verifyTenantOtp(
    String identifier,
    String otp,
  ) async {
    final trimmedId = identifier.trim();
    final trimmedOtp = otp.trim();

    if (trimmedId.isEmpty || trimmedOtp.isEmpty) {
      throw Exception('Username/Email and OTP are required');
    }
    if (trimmedOtp.length != 6) {
      throw Exception('OTP must be 6 digits');
    }

    const endpoint = 'verify-otp';
    if (!_canRetry(endpoint)) {
      throw Exception(
          'Too many failed attempts. Please try again in 15 minutes.');
    }

    try {
      debugPrint('[AuthRepo][OTP] Verifying OTP for: $trimmedId');

      final data = await _api.verifyTenantOtp(trimmedId, trimmedOtp);

      debugPrint('[AuthRepo][OTP] Raw verify data: $data');

      final success = data['success'] == true;
      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final message = data['message'] as String? ??
          (success ? 'OTP verified' : 'Invalid OTP');

      if (!success) {
        _recordFailure(endpoint);
        throw Exception(message);
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        await storeAuthToken(accessToken);
        await storeUsername(trimmedId);

        // Store refresh token if available
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await _storage.write(key: 'refreshToken', value: refreshToken);
        }

        debugPrint('[AuthRepo][OTP] Tokens stored from verify');
      }

      // Reset failures on success
      _resetFailures(endpoint);

      return {
        'success': true,
        'token': accessToken,
        'refreshToken': refreshToken,
        'message': message,
      };
    } on DioException catch (e) {
      debugPrint('[AuthRepo][OTP] Dio Error: ${e.message}');
      _recordFailure(endpoint);
      throw Exception('OTP verification failed');
    } catch (e) {
      debugPrint('[AuthRepo][OTP] Error (non‑Dio): $e');
      _recordFailure(endpoint);
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> lookupUsername(String contact) async {
    final trimmed = contact.trim();
    if (trimmed.isEmpty) {
      throw Exception('Email or phone is required');
    }

    const endpoint = 'lookup-username';
    if (!_canRetry(endpoint)) {
      throw Exception(
          'Too many failed attempts. Please try again in 15 minutes.');
    }

    try {
      debugPrint('[AuthRepo][FIND] Looking up username for: $trimmed');

      final data = await _api.lookupTenantUsername(trimmed);

      debugPrint('[AuthRepo][FIND] Raw lookup data: $data');

      final username = data['username']?.toString().trim();
      final message =
          data['message'] as String? ?? 'Username found successfully';

      if (username == null || username.isEmpty) {
        _recordFailure(endpoint);
        throw Exception('No username found for this contact');
      }

      // Reset failures on success
      _resetFailures(endpoint);

      return {
        'success': true,
        'username': username,
        'message': message,
      };
    } on DioException catch (e) {
      debugPrint('[AuthRepo][FIND] Dio Error: ${e.message}');
      _recordFailure(endpoint);
      throw Exception('No username found for this contact');
    } catch (e) {
      debugPrint('[AuthRepo][FIND] Error (non‑Dio): $e');
      _recordFailure(endpoint);
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> resendOtp(String identifier) async {
    await sendOtpForUsername(identifier);
  }

  // ===========================================================================
  // PROFILE COMPLETION CHECK
  // ===========================================================================

  Future<bool> hasCompleteProfile() async {
    try {
      return await _api.hasCompleteProfile();
    } catch (e) {
      debugPrint('[AuthRepo] Profile check error: $e');
      return false;
    }
  }

  // ===========================================================================
  // SESSION
  // ===========================================================================

  Future<void> storeAuthToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
    debugPrint('[AuthRepo][SESSION] Auth token stored');
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> storeUsername(String username) async {
    await _storage.write(key: _keyUsername, value: username);
    debugPrint('[AuthRepo][SESSION] Username stored: $username');
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: _keyUsername);
  }

  Future<void> setRegistrationComplete(bool complete) async {
    await _storage.write(key: _keyIsRegistered, value: complete.toString());
    debugPrint('[AuthRepo][SESSION] Registration complete: $complete');
  }

  Future<bool> isRegistrationComplete() async {
    final value = await _storage.read(key: _keyIsRegistered);
    return value == 'true';
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    // Clear retry counters
    _failedAttempts.clear();
    _lastFailedTime.clear();
    debugPrint('[AuthRepo][SESSION] User logged out, all data cleared');
  }
}
