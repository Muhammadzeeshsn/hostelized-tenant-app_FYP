import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.title = 'Verify OTP'});

  final String title; // <-- this fixes the router error

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _c = TextEditingController();
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    if (_c.text.trim() == '123456') {
      context.go('/register/form'); // or next step in your flow
    } else {
      setState(() => _err = 'Invalid OTP');
    }
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _c,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter 123456'),
            ),
            if (_err != null) ...[
              const SizedBox(height: 8),
              Text(
                _err!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _verify,
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
