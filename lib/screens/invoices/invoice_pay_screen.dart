// lib/screens/invoices/invoice_pay_screen.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../api/tenant_api.dart';
import '../../providers/providers.dart';
import 'package:go_router/go_router.dart';

class InvoicePayScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  const InvoicePayScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoicePayScreen> createState() => _InvoicePayScreenState();
}

class _InvoicePayScreenState extends ConsumerState<InvoicePayScreen> {
  bool _busy = false;
  String? _url;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _busy = true);
    try {
      // Placeholder gateway — just show the URL we would open
      final url = await ref
          .read(apiProvider)
          .initiateCheckout(widget.invoiceId);
      setState(() => _url = url);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay Invoice')),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Payment is in sandbox/placeholder mode.'),
                  const SizedBox(height: 8),
                  SelectableText(_url ?? ''),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      // Pretend success: refresh providers and go back
                      ref.invalidate(invoicesProvider);
                      ref.invalidate(paymentsProvider);
                      context.go('/invoices');
                    },
                    child: const Text('Mark as Paid (Mock)'),
                  ),
                ],
              ),
            ),
    );
  }
}
