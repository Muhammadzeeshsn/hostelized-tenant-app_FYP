// lib/providers/providers.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Already correct!

import '../api/tenant_api.dart';

/// Shared secure storage instance
final storageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

/// Tenant API wrapper
final apiProvider = Provider<TenantApi>((_) => TenantApi());

/// Auth state
final authStateProvider = StateProvider<bool>((_) => false);

/// Home dashboard data
final homeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.getHome();
});

/// Invoices list
final invoicesProvider =
    FutureProvider.family<Map<String, dynamic>, String?>((ref, status) async {
  final api = ref.watch(apiProvider);
  return api.listInvoices(status: status);
});

/// Payments list
final paymentsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.listPayments();
});

/// Support tickets
final ticketsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.listTickets();
});

/// Notices
final noticesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.listNotices();
});

/// Tenant profile
final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.getProfile();
});
