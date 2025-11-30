// lib/router.dart

import 'package:go_router/go_router.dart';

import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/find_username_screen.dart';

import 'screens/register/registration_form_screen.dart';
import 'screens/register/docs_upload_screen.dart';
import 'screens/register/verify_identity_screen.dart';
import 'screens/register/registration_success_screen.dart';

import 'screens/home/home_shell.dart';

final router = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/otp',
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
      path: '/find-username',
      builder: (_, __) => const FindUsernameScreen(),
    ),

    // Registration flow
    GoRoute(
      path: '/register/form',
      builder: (_, __) => const RegistrationFormScreen(),
    ),
    GoRoute(
      path: '/register/docs',
      builder: (_, __) => const DocsUploadScreen(),
    ),
    GoRoute(
      path: '/register/verify',
      builder: (_, __) => const VerifyIdentityScreen(),
    ),
    GoRoute(
      path: '/register/success',
      builder: (_, __) => const RegistrationSuccessScreen(),
    ),

    GoRoute(path: '/dashboard', builder: (_, __) => const HomeShell()),
  ],
);
