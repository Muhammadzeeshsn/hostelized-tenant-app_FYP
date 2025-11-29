// lib/screens/auth/otp_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_repo.dart';
import '../../api/tenant_api.dart';
import '../../theme.dart';

class OtpScreen extends StatefulWidget {
  final String title;
  final String username;
  final String? contactMasked;

  const OtpScreen({
    super.key,
    required this.title,
    required this.username,
    this.contactMasked,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otp = TextEditingController();
  bool _busy = false;
  String? _err;

  late final AuthRepo _repo = AuthRepo(
    const FlutterSecureStorage(),
    TenantApi(),
  );

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final username = widget.username.trim();

    if (username.isEmpty) {
      setState(() => _err = 'Missing context. Please go back and login again.');
      return;
    }

    final code = _otp.text.trim();
    if (code.isEmpty) {
      setState(() => _err = 'Please enter the OTP sent to you.');
      return;
    }

    setState(() {
      _busy = true;
      _err = null;
    });

    final ok = await _repo.verifyTenantOtp(username, code);

    if (!mounted) return;

    if (ok) {
      context.go('/dashboard');
    } else {
      setState(() => _err = 'Invalid or expired OTP. Please try again.');
    }

    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final masked = widget.contactMasked;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBrandBlue,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the 6-digit code sent to your registered contact.',
                style: t.textTheme.titleMedium,
              ),
              if (masked != null && masked.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  masked,
                  style: t.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: kBrandBlue,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              TextField(
                controller: _otp,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'OTP code',
                  counterText: '',
                ),
              ),
              if (_err != null) ...[
                const SizedBox(height: 8),
                Text(_err!, style: TextStyle(color: t.colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _handleVerify,
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
