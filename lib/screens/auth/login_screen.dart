// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../api/tenant_api.dart';
import '../../auth/auth_repo.dart';
import '../../routes.dart';
import '../../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;

  late final AuthRepo _repo = AuthRepo(
    const FlutterSecureStorage(),
    TenantApi(),
  );

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_busy) {
      debugPrint('[LOGIN] Already busy, ignoring tap');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      debugPrint('[LOGIN] Form validation failed');
      return;
    }

    final username = _usernameCtrl.text.trim();
    debugPrint('[LOGIN] Attempting login for username: $username');

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await _repo.sendOtpForUsername(username).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception(
                'Request timed out. Please check your connection.'),
          );

      debugPrint('[LOGIN] OTP sent successfully');

      if (!mounted) return;

      context.push(
        '${AppRoutes.otp}?username=${Uri.encodeComponent(username)}&title=Login OTP',
      );
    } catch (e) {
      debugPrint('[LOGIN] Login failed: $e');

      if (!mounted) return;

      String message = e.toString();
      if (message.contains('Exception: ')) {
        message = message.replaceFirst('Exception: ', '');
      }

      if (message.contains('Username not found') ||
          message.contains('invalid') ||
          message.contains('Invalid')) {
        message = 'Username not found. Please check and try again.';
      } else if (message.contains('Network')) {
        message = 'Network error. Please check your internet connection.';
      } else if (message.contains('timeout')) {
        message = 'Request timed out. Please check your connection.';
      }

      setState(() {
        _error = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          debugPrint('[LOGIN] Busy state reset');
        });
      }
    }
  }

  void _goToFindUsername() {
    context.push(AppRoutes.findUsername);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Tenant Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.welcome),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome Back',
                  style: t.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kBrandBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your username to receive OTP',
                  style:
                      t.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your unique username',
                    prefixIcon: Icon(Icons.person_outline, color: kBrandBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }
                    if (value.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleLogin(),
                  textInputAction: TextInputAction.go,
                  enabled: !_busy,
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _busy ? null : _handleLogin,
                    style: FilledButton.styleFrom(
                      backgroundColor: kBrandBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Send OTP',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton.icon(
                    onPressed: _busy ? null : _goToFindUsername,
                    icon: Icon(Icons.help_outline, size: 18, color: kBrandBlue),
                    label: Text(
                      'Forgot your username?',
                      style: TextStyle(
                          color: kBrandBlue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
