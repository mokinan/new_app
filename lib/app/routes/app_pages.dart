import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:new_app/app/routes/app_routes.dart';
import 'package:new_app/features/home/home_view.dart';
import 'package:new_app/features/login/login_binding.dart';
import 'package:new_app/features/login/login_view.dart';
import 'package:new_app/features/register/register_binding.dart';
import 'package:new_app/features/register/register_view.dart';
import 'package:new_app/features/session/session_controller.dart';
import 'package:new_app/features/splash/splash_binding.dart';
import 'package:new_app/features/splash/splash_view.dart';
import 'package:new_app/features/welcome/welcome_binding.dart';
import 'package:new_app/features/welcome/welcome_view.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.splash, page: SplashView.new, binding: SplashBinding()),
    GetPage(name: AppRoutes.welcome, page: WelcomeView.new, binding: WelcomeBinding()),
    GetPage(name: AppRoutes.login, page: LoginView.new, binding: LoginBinding()),
    GetPage(name: AppRoutes.register, page: RegisterView.new, binding: RegisterBinding()),
    GetPage(name: AppRoutes.home, page: HomeView.new, middlewares: [AuthGuard()]),
  ];
}

/// Keeps signed-out users away from protected routes.
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      SessionController.to.isLoggedIn ? null : const RouteSettings(name: AppRoutes.login);
}
