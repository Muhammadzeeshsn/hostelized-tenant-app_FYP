// lib/services/tenant_registration_storage.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tenant_registration_draft.dart';

/// Persists registration draft locally
class TenantRegistrationStorage {
  static const String _key = 'tenant_registration_draft';

  Future<TenantRegistrationDraft> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);

      if (jsonString == null || jsonString.isEmpty) {
        return const TenantRegistrationDraft.empty();
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return TenantRegistrationDraft.fromJson(jsonMap);
    } catch (e) {
      debugPrint('[TenantRegistrationStorage] Load error: $e');
      return const TenantRegistrationDraft.empty();
    }
  }

  Future<void> save(TenantRegistrationDraft draft) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(draft.toJson());
      await prefs.setString(_key, jsonString);
      debugPrint('[TenantRegistrationStorage] Draft saved');
    } catch (e) {
      debugPrint('[TenantRegistrationStorage] Save error: $e');
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      debugPrint('[TenantRegistrationStorage] Draft cleared');
    } catch (e) {
      debugPrint('[TenantRegistrationStorage] Clear error: $e');
    }
  }
}
