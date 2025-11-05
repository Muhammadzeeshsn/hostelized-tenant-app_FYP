import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../api/tenant_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storageProvider = Provider((_) => const FlutterSecureStorage());
final apiProvider = Provider((_) => TenantApi());

final authStateProvider = StateProvider<bool>((_) => false); // logged-in?

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
