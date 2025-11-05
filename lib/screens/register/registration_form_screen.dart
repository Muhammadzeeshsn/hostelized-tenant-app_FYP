// lib/screens/register/registration_form_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegistrationFormScreen extends StatefulWidget {
  const RegistrationFormScreen({super.key});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _roll = TextEditingController();
  final _dob = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _roll.dispose();
    _dob.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<bool> _askOtp(BuildContext context, {required String target}) async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Enter OTP for $target'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '123456'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text.trim() == '123456'),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _busy = false);
    context.go('/register/docs');
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF003A60);
    const smallBtnSize = Size(110, 44); // <-- finite constraints

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
        automaticallyImplyLeading: true,
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: ColoredBox(
        color: navy,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _name,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _roll,
                              decoration: const InputDecoration(
                                labelText: 'Roll no.',
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dob,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Email + Verify (button gets finite width)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _email,
                              decoration: const InputDecoration(
                                labelText: 'Email address',
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: smallBtnSize.width,
                            height: smallBtnSize.height,
                            child: FilledButton(
                              onPressed: () async {
                                final ok = await _askOtp(
                                  context,
                                  target: _email.text.trim().isEmpty
                                      ? 'email'
                                      : _email.text.trim(),
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok ? 'Email verified' : 'OTP invalid',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Verify'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Phone + Send OTP (finite width)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phone,
                              decoration: const InputDecoration(
                                labelText: 'Contact number',
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: smallBtnSize.width,
                            height: smallBtnSize.height,
                            child: FilledButton(
                              onPressed: () async {
                                final ok = await _askOtp(
                                  context,
                                  target: _phone.text.trim().isEmpty
                                      ? 'phone'
                                      : _phone.text.trim(),
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok ? 'Phone verified' : 'OTP invalid',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Send OTP'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: (v) =>
                            (v == null || v.length < 6) ? 'Min 6 chars' : null,
                      ),
                      const SizedBox(height: 20),

                      // Primary submit (stretches full width safely)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _busy ? null : _submit,
                          child: _busy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Authenticate'),
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => context.go('/register/docs'),
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
