import 'package:get/get.dart';
import '../../features/home/views/home_view.dart';
import '../../features/login/bindings/login_binding.dart';
import '../../features/login/views/login_view.dart';
import '../../features/register/bindings/register_binding.dart';
import '../../features/register/views/register_view.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/views/splash_view.dart';
import '../../features/welcome/bindings/welcome_binding.dart';
import '../../features/welcome/views/welcome_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name:    AppRoutes.splash,
      page:    () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name:    AppRoutes.welcome,
      page:    () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name:    AppRoutes.login,
      page:    () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name:    AppRoutes.register,
      page:    () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
    ),
  ];
}
