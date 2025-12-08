// lib/screens/auth/otp_screen.dart (Updated navigation)

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
  bool _resendBusy = false;
  String? _error;
  bool _showSuccess = false;
  int _resendCountdown = 0;

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
    if (_busy) {
      debugPrint('[OTP][UI] Already busy, ignoring verify');
      return;
    }

    final username = widget.username.trim();
    final code = _otp.text.trim();

    debugPrint('[OTP][UI] Verifying $username with code: <hidden>');

    if (code.length != 6) {
      setState(() {
        _error = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final response = await _repo.verifyTenantOtp(username, code).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception(
                'OTP verification timed out. Please try again.'),
          );

      debugPrint('[OTP][UI] Verify response: $response');

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          _showSuccess = true;
        });

        // Check if profile is complete
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        final hasCompleteProfile = await _repo.hasCompleteProfile();

        if (hasCompleteProfile) {
          // Profile is complete, go to dashboard
          await _repo.setRegistrationComplete(true);
          context.go(AppRoutes.dashboard);
        } else {
          // Profile is incomplete, go to registration flow
          await _repo.setRegistrationComplete(false);
          context.go(AppRoutes.onboardingTenant, extra: username);
        }
      } else {
        final message = response['message'] as String? ?? 'Invalid OTP';
        setState(() {
          _error = message;
        });
      }
    } catch (e) {
      debugPrint('[OTP][UI] Error: $e');

      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          debugPrint('[OTP][UI] Busy state reset');
        });
      }
    }
  }

  Future<void> _handleResendOtp() async {
    if (_resendBusy || _resendCountdown > 0) {
      debugPrint('[OTP][UI] Resend already busy or in cooldown');
      return;
    }

    final username = widget.username.trim();
    debugPrint('[OTP][UI] Resend OTP for: $username');

    setState(() {
      _resendBusy = true;
      _error = null;
    });

    try {
      await _repo.resendOtp(username).timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw Exception('Resend request timed out. Please try again.'),
          );

      if (!mounted) return;

      _otp.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        _resendCountdown = 30;
      });

      for (int i = 30; i > 0; i--) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _resendCountdown = i - 1;
          });
        }
      }

      debugPrint('[OTP][UI] Resend cooldown completed');
    } catch (e) {
      debugPrint('[OTP][UI] Resend error: $e');

      if (!mounted) return;

      setState(() {
        _error = 'Failed to resend OTP: '
            '${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _resendBusy = false;
          debugPrint('[OTP][UI] Resend busy state reset');
        });
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
              const SizedBox(height: 8),
              Text(
                'Checking profile completion...',
                style: TextStyle(color: Colors.green[600]),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                color: Colors.green,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
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
              Text(
                'Enter OTP Code',
                style: t.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kBrandBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to your registered contact',
                style: t.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
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
              TextField(
                controller: _otp,
                keyboardType: TextInputType.number,
                maxLength: 6,
                enabled: !_busy,
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
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color:
                            (Colors.grey[300] ?? Colors.grey).withOpacity(0.5),
                        width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (_error != null) {
                    setState(() {
                      _error = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
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
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _resendBusy || _resendCountdown > 0
                      ? null
                      : _handleResendOtp,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: kBrandBlue, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _resendBusy
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(kBrandBlue),
                          ),
                        )
                      : Text(
                          _resendCountdown > 0
                              ? 'Resend OTP in $_resendCountdown s'
                              : 'Resend OTP',
                          style: TextStyle(
                            color: kBrandBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
