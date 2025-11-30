// lib/screens/auth/find_username_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_repo.dart';
import '../../api/tenant_api.dart';
import '../../theme.dart';

class FindUsernameScreen extends StatefulWidget {
  const FindUsernameScreen({super.key});

  @override
  State<FindUsernameScreen> createState() => _FindUsernameScreenState();
}

class _FindUsernameScreenState extends State<FindUsernameScreen> {
  final _contactCtrl = TextEditingController();
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
    final contact = _contactCtrl.text.trim();
    debugPrint('[FindUsernameScreen] _handleSearch contact=$contact');

    if (contact.isEmpty) {
      setState(() {
        _error = 'Please enter your registered email or phone number.';
        _foundUsername = null;
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _foundUsername = null;
    });

    try {
      final username = await _repo.lookupUsername(contact);
      if (!mounted) return;

      if (username == null || username.isEmpty) {
        debugPrint(
          '[FindUsernameScreen] lookup returned null/empty username for contact=$contact',
        );
        setState(() {
          _error = 'No username found for this contact.';
        });
        return;
      }

      debugPrint(
        '[FindUsernameScreen] lookup OK contact=$contact username=$username',
      );

      setState(() {
        _foundUsername = username;
      });

      // optional dialog to highlight the username
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Your username'),
          content: Text(
            'We found this username associated with your contact:\n\n$username',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e, st) {
      debugPrint('[FindUsernameScreen] ERROR: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = 'Failed to lookup username. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _handleBack() {
    debugPrint('[FindUsernameScreen] back pressed -> /login');
    context.go('/login'); // avoids "There is nothing to pop"
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find your username'),
        foregroundColor: Colors.white,
        backgroundColor: kBrandBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your registered email or phone number.',
                style: t.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contactCtrl,
                decoration: const InputDecoration(labelText: 'Email or phone'),
              ),
              const SizedBox(height: 16),
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: t.colorScheme.error)),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: _busy ? null : _handleSearch,
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Search'),
              ),
              const SizedBox(height: 24),
              if (_foundUsername != null) ...[
                Text('Found username:', style: t.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  _foundUsername!,
                  style: t.textTheme.titleLarge?.copyWith(
                    color: kBrandBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
