class ApiEndpoints {
  ApiEndpoints._();

  // ─── Onboarding ───────────────────────────────────────────
  static const String onboardingSlides = '/onboarding/slides';

  // ─── Auth ─────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // ─── User ─────────────────────────────────────────────────
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
}
