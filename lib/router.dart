// lib/router.dart (Updated)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/find_username_screen.dart';
import 'screens/home/home_shell.dart';
import 'screens/onboarding/tenant_registration_flow.dart';

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

    // NOTE: Legacy registration routes have been removed
    // They are replaced by TenantRegistrationFlow
  ],
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
              const Text(
                'Page Not Found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The route "${state.uri}" does not exist.',
                style: const TextStyle(fontSize: 16),
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
