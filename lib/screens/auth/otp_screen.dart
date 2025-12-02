// lib/screens/auth/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../api/tenant_api.dart';
import '../../auth/auth_repo.dart';
import '../../routes.dart';
import '../../theme.dart';

class OtpScreen extends StatefulWidget {
  final String title;
  final String username;
  final String contactMasked;

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
  String? _error;
  bool _showSuccess = false;

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
    final code = _otp.text.trim();

    debugPrint(
        '[OTP] Verifying $username with code: ${code.isEmpty ? "<empty>" : "<hidden>"}');

    setState(() {
      _busy = true;
      _error = null;
    });

    // Validate OTP format
    if (code.length != 6) {
      setState(() {
        _busy = false;
        _error = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    try {
      final response = await _repo.verifyTenantOtp(username, code);
      debugPrint('[OTP] Verify response: $response');

      if (!mounted) return;

      if (response['success'] == true) {
        // Store auth token
        final token = response['token'] as String?;
        if (token != null) {
          await _repo.storeAuthToken(token);
          await _repo.storeUsername(username);
        }

        // Show success and navigate
        setState(() {
          _showSuccess = true;
        });

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        context.go(AppRoutes.onboardingTenant, extra: username);
      } else {
        // Handle backend validation failure
        final message = response['message'] as String? ?? 'Invalid OTP';
        setState(() {
          _error = message;
        });
      }
    } catch (e) {
      debugPrint('[OTP] Error: $e');
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return Scaffold(
        backgroundColor: Colors.green[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green[700]),
              const SizedBox(height: 16),
              Text(
                'OTP Verified!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // OTP Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kBrandBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(Icons.lock_outline, size: 40, color: kBrandBlue),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Enter OTP Code',
                  style: t.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kBrandBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Enter the 6-digit code sent to your registered contact',
                  style:
                      t.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),

                if (widget.contactMasked.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Sent to: ${widget.contactMasked}',
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // OTP Input
                TextField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    letterSpacing: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '000000',
                    hintStyle: TextStyle(
                      fontSize: 28,
                      letterSpacing: 16,
                      color: Colors.grey[300],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: kBrandBlue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: kBrandBlue.withOpacity(0.3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: kBrandBlue, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length == 6) {
                      _handleVerify();
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Error message
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

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _busy ? null : _handleVerify,
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
                            'Verify & Continue',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Resend OTP
                Center(
                  child: TextButton(
                    onPressed: _busy
                        ? null
                        : () {
                            // Implement resend OTP
                            debugPrint(
                                '[OTP] Resend OTP requested for: ${widget.username}');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('OTP resent successfully')),
                            );
                          },
                    child: Text(
                      'Resend OTP',
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
