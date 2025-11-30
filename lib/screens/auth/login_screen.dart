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
    final identifier = _username.text.trim();

    setState(() {
      _busy = true;
      _err = null;
    });

    debugPrint('[LoginScreen] _handleSendOtp identifier=$identifier');

    if (identifier.isEmpty) {
      setState(() {
        _busy = false;
        _err = 'Please enter your username.';
      });
      return;
    }

    final ok = await _repo.sendOtpForUsername(identifier);

    if (!mounted) return;

    if (ok) {
      debugPrint('[LoginScreen] OTP send success, navigating to /otp');

      context.go(
        '/otp?title=${Uri.encodeComponent('Login OTP')}'
        '&username=${Uri.encodeComponent(identifier)}',
      );
    } else {
      debugPrint('[LoginScreen] OTP send failed');
      setState(() {
        _err = 'Could not send OTP. Please check your username and try again.';
      });
    }

    if (mounted) {
      setState(() => _busy = false);
    }
  }

  void _openFindUsername() {
    debugPrint('[LoginScreen] Navigating to /find-username');
    context.go('/find-username');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Login'),
        foregroundColor: Colors.white,
        backgroundColor: kBrandBlue,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const SizedBox(height: 16),
            Text(
              'Sign in with your username',
              style: t.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'We will send a login code to your registered email.',
              style: t.textTheme.bodyMedium?.copyWith(color: Colors.black54),
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
                      height: 22,
                      width: 22,
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
