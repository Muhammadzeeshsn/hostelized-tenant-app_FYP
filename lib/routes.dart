// lib/routes.dart
/// Centralized route definitions to prevent navigation errors
class AppRoutes {
  // Auth Flow
  static const welcome = '/welcome';
  static const login = '/login';
  static const otp = '/otp';
  static const findUsername = '/find-username';

  // Registration Flow
  static const onboardingTenant = '/onboarding/tenant';

  // Main App
  static const dashboard = '/dashboard';

  // Legacy routes (can be removed after migration)
  static const registerForm = '/register/form';
  static const registerDocs = '/register/docs';
  static const registerVerify = '/register/verify';
  static const registerSuccess = '/register/success';
}
