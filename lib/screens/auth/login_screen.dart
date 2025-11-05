import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_repo.dart';
import '../../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _err;

  late final AuthRepo _repo = AuthRepo(const FlutterSecureStorage());

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _busy = true;
      _err = null;
    });

    final ok = await _repo.signInLocal(_user.text.trim(), _pass.text);
    if (!mounted) return;

    if (ok) {
      // Navigate to OTP screen with a title via the query string
      context.go('/otp?title=Login%20OTP');
    } else {
      setState(() => _err = 'Invalid username or password');
    }

    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 36),

            // Logo block (drop shape from prototype)
            Center(
              child: Container(
                width: 112,
                height: 112,
                decoration: const BoxDecoration(
                  color: kBrandBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(56),
                    topRight: Radius.circular(56),
                    bottomLeft: Radius.circular(56),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'HMS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'Welcome Back!',
                style: t.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Please enter your details.',
                style: t.textTheme.titleMedium?.copyWith(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _user,
              decoration: const InputDecoration(labelText: 'Enter username'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _pass,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Center(
              child: Text(
                'Recovery Password',
                style: t.textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
            ),

            if (_err != null) ...[
              const SizedBox(height: 8),
              Text(_err!, style: TextStyle(color: t.colorScheme.error)),
            ],

            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _handleSignIn,
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign In'),
            ),

            const SizedBox(height: 20),
            const Divider(indent: 60, endIndent: 60),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Not a member? '),
                GestureDetector(
                  onTap: () => context.go('/register/form'),
                  child: const Text(
                    'Register now',
                    style: TextStyle(
                      color: kBrandBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Demo accounts → ali.khan/Ali@123 • fatima.zaidi/F@tima!456 • zeeshan/Zeeshan#789',
              style: TextStyle(color: Colors.black45, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
