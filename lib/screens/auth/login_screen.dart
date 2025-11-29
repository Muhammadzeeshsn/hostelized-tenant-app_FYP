// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_repo.dart';
import '../../api/tenant_api.dart';
import '../../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  bool _busy = false;
  String? _err;

  late final AuthRepo _repo = AuthRepo(
    const FlutterSecureStorage(),
    TenantApi(),
  );

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final username = _username.text.trim();

    if (username.isEmpty) {
      setState(() => _err = 'Please enter your username.');
      return;
    }

    setState(() {
      _busy = true;
      _err = null;
    });

    final result = await _repo.sendOtpForUsername(username);

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _err = 'Could not send OTP. Please check your username and try again.';
        _busy = false;
      });
      return;
    }

    final contactMasked = result['contactMasked'] ?? '';

    final encodedUsername = Uri.encodeComponent(username);
    final encodedContact = Uri.encodeComponent(contactMasked);

    context.go(
      '/otp?title=Login%20OTP&username=$encodedUsername&contactMasked=$encodedContact',
    );

    setState(() => _busy = false);
  }

  void _openFindUsername() {
    context.push('/find-username');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBrandBlue,
        foregroundColor: Colors.white,
        title: const Text('Tenant Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Sign in with your username',
                style: t.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'We will send a login code to your registered email.',
                style: t.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _openFindUsername,
                child: const Text('Forgot username?'),
              ),
            ),
            if (_err != null) ...[
              const SizedBox(height: 8),
              Text(_err!, style: TextStyle(color: t.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _handleSendOtp,
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send OTP'),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Demo tenant username (from seed): SEEDA260',
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
