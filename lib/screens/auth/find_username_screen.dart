// lib/screens/auth/find_username_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../api/tenant_api.dart';
import '../../auth/auth_repo.dart';
import '../../routes.dart';
import '../../theme.dart';

class FindUsernameScreen extends StatefulWidget {
  const FindUsernameScreen({super.key});

  @override
  State<FindUsernameScreen> createState() => _FindUsernameScreenState();
}

class _FindUsernameScreenState extends State<FindUsernameScreen> {
  final _contactCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;
  String? _foundUsername;

  late final AuthRepo _repo = AuthRepo(
    const FlutterSecureStorage(),
    TenantApi(),
  );

  @override
  void dispose() {
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    if (_busy) {
      debugPrint('[FIND_USERNAME][UI] Already busy, ignoring tap');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      debugPrint('[FIND_USERNAME][UI] Form validation failed');
      return;
    }

    final contact = _contactCtrl.text.trim();
    debugPrint('[FIND_USERNAME][UI] Searching for: $contact');

    setState(() {
      _busy = true;
      _error = null;
      _foundUsername = null;
    });

    try {
      final response = await _repo.lookupUsername(contact).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception(
              'Request timed out. Please check your connection.',
            ),
          );

      debugPrint('[FIND_USERNAME][UI] Response: $response');

      if (!mounted) return;

      final username = response['username'] as String?;
      final message = response['message'] as String?;

      if (username != null && username.trim().isNotEmpty) {
        setState(() {
          _foundUsername = username.trim();
          _error = null;
        });
      } else {
        setState(() {
          _error = message ?? 'No username found for this contact';
          _foundUsername = null;
        });
      }
    } catch (e) {
      debugPrint('[FIND_USERNAME][UI] Error: $e');

      if (!mounted) return;

      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring('Exception: '.length);
      }

      setState(() {
        _error = message;
        _foundUsername = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          debugPrint('[FIND_USERNAME][UI] Busy state reset');
        });
      }
    }
  }

  void _proceedWithUsername() {
    final username = _foundUsername?.trim();
    if (username != null && username.isNotEmpty) {
      context.push(
        '${AppRoutes.otp}?username=${Uri.encodeComponent(username)}&title=Forgot Username OTP',
      );
    }
  }

  void _resetSearch() {
    setState(() {
      _foundUsername = null;
      _error = null;
      _contactCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Find Username',
          style: TextStyle(fontWeight: FontWeight.bold),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Find Your Username',
                  style: t.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kBrandBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your registered email or phone number',
                  style:
                      t.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Contact field
                TextFormField(
                  controller: _contactCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email or Phone Number',
                    hintText: 'john@example.com or +92 300 1234567',
                    prefixIcon:
                        Icon(Icons.contact_mail_outlined, color: kBrandBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email or phone';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleSearch(),
                  enabled: !_busy,
                  textInputAction: TextInputAction.search,
                ),

                const SizedBox(height: 16),

                // Error message banner
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

                // Success message + actions
                if (_foundUsername != null &&
                    _foundUsername!.trim().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your username:',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _foundUsername!,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _proceedWithUsername,
                      style: FilledButton.styleFrom(
                        backgroundColor: kBrandBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Proceed to OTP',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _resetSearch,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: kBrandBlue, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Search Again',
                        style: TextStyle(
                          color: kBrandBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],

                if (_foundUsername == null) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _busy ? null : _handleSearch,
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
                              'Search Username',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
