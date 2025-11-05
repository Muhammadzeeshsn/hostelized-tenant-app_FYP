import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/providers.dart';
import 'package:go_router/go_router.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider(null));
    return Scaffold(
      appBar: AppBar(title: const Text('Invoices')),
      body: invoices.when(
        data: (d) {
          final items = (d['items'] as List?) ?? [];
          if (items.isEmpty)
            return const Center(child: Text('No invoices yet.'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final inv = items[i] as Map<String, dynamic>;
              return ListTile(
                title: Text('Period: ${inv['period']}'),
                subtitle: Text(
                  'Amount: Rs ${inv['amount']} • ${inv['status']}',
                ),
                trailing: FilledButton(
                  onPressed: () => context.go('/pay', extra: inv),
                  child: const Text('Pay'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
