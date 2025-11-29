// lib/providers/providers.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/tenant_api.dart';
import '../auth/auth_repo.dart';

// Storage
final storageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

// Single TenantApi instance
final apiProvider = Provider<TenantApi>((_) => TenantApi());

// Auth repo (uses secure storage + TenantApi)
final authRepoProvider = Provider<AuthRepo>((ref) {
  final storage = ref.watch(storageProvider);
  final api = ref.watch(apiProvider);
  return AuthRepo(storage, api);
});

// Basic logged-in flag if you still need it
final authStateProvider = StateProvider<bool>((_) => false);

// ---------------- Data providers ----------------

final homeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.getHome();
});

final invoicesProvider = FutureProvider.family<Map<String, dynamic>, String?>((
  ref,
  status,
) async {
  final api = ref.watch(apiProvider);
  return api.listInvoices(status: status);
});

final paymentsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.listPayments();
});

final ticketsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.listTickets();
});

final noticesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.listNotices();
});

final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.getProfile();
});
