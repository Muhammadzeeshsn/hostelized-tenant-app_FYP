// lib/providers/providers.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../api/tenant_api.dart';

/// Shared secure storage instance (used by DioClient via FlutterSecureStorage).
final storageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

/// Tenant API wrapper (HTTP client).
final apiProvider = Provider<TenantApi>((_) => TenantApi());

/// Simple auth flag – true when user is logged in.
final authStateProvider = StateProvider<bool>((_) => false);

/// Home dashboard data for tenant.
final homeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.getHome();
});

/// Invoices list, optionally filtered by status.
final invoicesProvider = FutureProvider.family<Map<String, dynamic>, String?>((
  ref,
  status,
) async {
  final api = ref.watch(apiProvider);
  return api.listInvoices(status: status);
});

/// Payments / receipts list.
final paymentsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.listPayments();
});

/// Support tickets list.
final ticketsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.listTickets();
});

/// Notices list.
final noticesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.listNotices();
});

/// Tenant profile.
final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.getProfile();
});
