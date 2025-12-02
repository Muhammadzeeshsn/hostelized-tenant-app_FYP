// lib/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/find_username_screen.dart';
import 'screens/home/home_shell.dart';
import 'screens/onboarding/tenant_registration_flow.dart';

// Legacy screens (remove if not needed)
import 'screens/register/registration_form_screen.dart';
import 'screens/register/docs_upload_screen.dart';
import 'screens/register/verify_identity_screen.dart';
import 'screens/register/registration_success_screen.dart';

/// Main router configuration
final router = GoRouter(
  initialLocation: AppRoutes.welcome,
  routes: [
    GoRoute(
      path: AppRoutes.welcome,
      builder: (_, __) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (_, state) {
        final qp = state.uri.queryParameters;
        return OtpScreen(
          title: qp['title'] ?? 'Login OTP',
          username: qp['username'] ?? '',
          contactMasked: qp['contactMasked'] ?? '',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.findUsername,
      builder: (_, __) => const FindUsernameScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingTenant,
      builder: (_, state) => TenantRegistrationFlow(
        username: state.extra as String?,
      ),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (_, __) => const HomeShell(),
    ),

    // Legacy routes (remove these if no longer used)
    GoRoute(
      path: AppRoutes.registerForm,
      builder: (_, __) => const RegistrationFormScreen(),
    ),
    GoRoute(
      path: AppRoutes.registerDocs,
      builder: (_, __) => const DocsUploadScreen(),
    ),
    GoRoute(
      path: AppRoutes.registerVerify,
      builder: (_, __) => const VerifyIdentityScreen(),
    ),
    GoRoute(
      path: AppRoutes.registerSuccess,
      builder: (_, __) => const RegistrationSuccessScreen(),
    ),
  ],

  // Comprehensive error handling for unknown routes
  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Error'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              const SizedBox(height: 24),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The route "${state.uri}" does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.welcome),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Go to Welcome'),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
