import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/features/home/home_page.dart';
import 'package:new_app/features/login/login_page.dart';
import 'package:new_app/features/register/register_page.dart';
import 'package:new_app/features/session/session_notifier.dart';
import 'package:new_app/features/splash/splash_page.dart';
import 'package:new_app/features/welcome/welcome_page.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
}

/// Override for deep links (e.g. a notification opening `/home`).
final initialLocationProvider = Provider<String>((ref) => AppRoutes.splash);

/// Navigation follows the session: signing in or out moves the user without
/// any screen calling `go` itself, and `/home` is unreachable signed out
/// (deep links included).
final routerProvider = Provider<GoRouter>((ref) {
  // Bridges Riverpod → go_router: notify the router when the session changes,
  // without rebuilding (and losing) the router itself.
  final refresh = ValueNotifier(0);
  ref
    ..listen(sessionProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: ref.read(initialLocationProvider),
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = ref.read(sessionProvider) != null;
      final location = state.matchedLocation;
      const authPages = {AppRoutes.login, AppRoutes.register};
      if (!loggedIn && location == AppRoutes.home) return AppRoutes.login;
      if (loggedIn && authPages.contains(location)) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: AppRoutes.welcome, builder: (_, _) => const WelcomePage()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: AppRoutes.register, builder: (_, _) => const RegisterPage()),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
