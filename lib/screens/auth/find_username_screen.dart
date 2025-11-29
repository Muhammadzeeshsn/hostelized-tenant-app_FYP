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
  final _contact = TextEditingController();
  bool _busy = false;
  String? _err;
  String? _foundUsername;

  late final AuthRepo _repo = AuthRepo(
    const FlutterSecureStorage(),
    TenantApi(),
  );

  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final contact = _contact.text.trim();
    if (contact.isEmpty) {
      setState(() => _err = 'Please enter your registered email or phone.');
      return;
    }

    setState(() {
      _busy = true;
      _err = null;
      _foundUsername = null;
    });

    final username = await _repo.lookupUsername(contact);

    if (!mounted) return;

    if (username == null) {
      setState(() {
        _err = 'Failed to lookup username. Please try again.';
        _busy = false;
      });
      return;
    }

    setState(() {
      _foundUsername = username;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBrandBlue,
        foregroundColor: Colors.white,
        title: const Text('Find your username'),
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
                'Enter your registered email or phone number.',
                style: t.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contact,
                decoration: const InputDecoration(labelText: 'Email or phone'),
              ),
              if (_err != null) ...[
                const SizedBox(height: 8),
                Text(_err!, style: TextStyle(color: t.colorScheme.error)),
              ],
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              if (_foundUsername != null) ...[
                Text('Your username:', style: t.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  _foundUsername!,
                  style: t.textTheme.headlineSmall?.copyWith(
                    color: kBrandBlue,
                    fontWeight: FontWeight.w700,
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
