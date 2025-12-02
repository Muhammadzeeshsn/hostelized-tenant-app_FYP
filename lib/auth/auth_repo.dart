// lib/auth/auth_repo.dart
import 'package:flutter/foundation.dart'; // Add for debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/tenant_api.dart';

/// Repository for tenant authentication and registration
class AuthRepo {
  final FlutterSecureStorage _storage;
  final TenantApi _api;

  // Secure storage keys
  static const String _keyToken = 'auth_token';
  static const String _keyUsername = 'username';
  static const String _keyIsRegistered = 'is_registered';

  AuthRepo(this._storage, this._api);

  // ===========================================================================
  // AUTHENTICATION METHODS
  // ===========================================================================

  /// Send OTP to the provided identifier (email/phone/username)
  Future<void> sendOtpForUsername(String identifier) async {
    debugPrint('[AuthRepo] Sending OTP for: $identifier');
    await _api.loginByUsername(identifier);
  }

  /// Verify OTP and return the response data
  Future<Map<String, dynamic>> verifyTenantOtp(
      String identifier, String otp) async {
    debugPrint('[AuthRepo] Verifying OTP for: $identifier');
    return await _api.verifyTenantOtp(identifier, otp);
  }

  /// Lookup username by email or phone
  Future<Map<String, dynamic>> lookupUsername(String contact) async {
    debugPrint('[AuthRepo] Looking up username for: $contact');
    return await _api.lookupTenantUsername(contact);
  }

  // ===========================================================================
  // SESSION MANAGEMENT
  // ===========================================================================

  /// Store authentication token
  Future<void> storeAuthToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
    debugPrint('[AuthRepo] Auth token stored');
  }

  /// Get stored authentication token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Check if user is logged in (has valid token)
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Store username
  Future<void> storeUsername(String username) async {
    await _storage.write(key: _keyUsername, value: username);
    debugPrint('[AuthRepo] Username stored: $username');
  }

  /// Get stored username
  Future<String?> getUsername() async {
    return await _storage.read(key: _keyUsername);
  }

  // ===========================================================================
  // REGISTRATION MANAGEMENT
  // ===========================================================================

  /// Mark registration as complete
  Future<void> setRegistrationComplete(bool complete) async {
    await _storage.write(key: _keyIsRegistered, value: complete.toString());
    debugPrint('[AuthRepo] Registration marked as complete: $complete');
  }

  /// Check if registration is complete
  Future<bool> isRegistrationComplete() async {
    final value = await _storage.read(key: _keyIsRegistered);
    return value == 'true';
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Clear all stored data (logout)
  Future<void> logout() async {
    await _storage.deleteAll();
    debugPrint('[AuthRepo] User logged out, all data cleared');
  }
}
