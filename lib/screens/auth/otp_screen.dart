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
  final String contactMasked; // currently we only show generic text

  const OtpScreen({
    super.key,
    required this.title,
    required this.username,
    this.contactMasked = '',
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
    final identifier = widget.username.trim();
    final code = _otp.text.trim();

    debugPrint(
      '[OtpScreen] _handleVerify username=$identifier otp=${code.isEmpty ? "<empty>" : "<entered>"}',
    );

    setState(() {
      _busy = true;
      _err = null;
    });

    if (identifier.isEmpty) {
      debugPrint(
        '[OtpScreen] missing username context, asking user to go back',
      );
      setState(() {
        _busy = false;
        _err = 'Missing context. Please go back and login again.';
      });
      return;
    }

    if (code.isEmpty) {
      debugPrint('[OtpScreen] empty otp field');
      setState(() {
        _busy = false;
        _err = 'Please enter the OTP sent to you.';
      });
      return;
    }

    // 🔑 THIS STILL USES verifyTenantOtp (no compile error)
    final ok = await _repo.verifyTenantOtp(identifier, code);
    debugPrint('[OtpScreen] verifyTenantOtp() result ok=$ok');

    if (!mounted) return;

    if (ok) {
      // ✅ CHANGE: go to registration flow instead of dashboard
      debugPrint(
        '[OtpScreen] OTP verify success, navigating to /register/form',
      );
      context.go('/register/form');
    } else {
      debugPrint('[OtpScreen] OTP verify failed');
      setState(() {
        _err = 'Invalid or expired OTP. Please try again.';
      });
    }

    if (mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: kBrandBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('[OtpScreen] back pressed, popping route');
            context.pop();
          },
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
