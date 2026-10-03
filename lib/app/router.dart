import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/features/home/home_page.dart';
import 'package:new_app/features/login/login_page.dart';
import 'package:new_app/features/register/register_page.dart';
import 'package:new_app/features/session/session_cubit.dart';
import 'package:new_app/features/splash/splash_page.dart';
import 'package:new_app/features/welcome/welcome_page.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
}

/// Navigation follows the session: signing in or out moves the user without
/// any screen calling `go` itself, and `/home` is unreachable signed out
/// (deep links included).
GoRouter createRouter(SessionCubit session, {String initialLocation = AppRoutes.splash}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: _StreamListenable(session.stream),
  redirect: (context, state) {
    final loggedIn = session.state.isLoggedIn;
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

class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
