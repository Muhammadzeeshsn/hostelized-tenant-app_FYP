import 'package:go_router/go_router.dart';

import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';

import 'screens/register/registration_form_screen.dart';
import 'screens/register/docs_upload_screen.dart';
import 'screens/register/verify_identity_screen.dart';
import 'screens/register/registration_success_screen.dart';

import 'screens/home/home_shell.dart';

/// Central app router
///
/// Notes:
/// • We keep a single shell route at /dashboard so there’s only one bottom bar.
/// • OTP route accepts an optional ?title=… query param.
/// • Registration flow stays linear: form → docs → verify → success.
final router = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/otp',
      builder: (_, s) =>
          OtpScreen(title: s.uri.queryParameters['title'] ?? 'Verify OTP'),
    ),

    // Registration
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

    // Single shell route (keeps one persistent bottom bar)
    GoRoute(path: '/dashboard', builder: (_, __) => const HomeShell()),
  ],
);
