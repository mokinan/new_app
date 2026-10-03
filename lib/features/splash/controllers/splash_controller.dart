import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/auth_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final auth   = AuthService.to;
      final config = AppConfig.to;

      if (auth.isLoggedIn) {
        // Add a timeout so a hanging secure-storage call never blocks the user
        final valid = await auth
            .hasValidToken()
            .timeout(const Duration(seconds: 4), onTimeout: () => false);

        Get.offAllNamed(valid ? AppRoutes.home : AppRoutes.login);
      } else if (config.isOnboarded) {
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.offAllNamed(AppRoutes.welcome);
      }
    } catch (_) {
      // Fallback: if anything fails just show login
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
