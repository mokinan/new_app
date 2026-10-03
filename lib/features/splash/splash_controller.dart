import 'package:get/get.dart';
import 'package:new_app/app/routes/app_routes.dart';
import 'package:new_app/core/services/preferences_service.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/features/session/session_controller.dart';

class SplashController extends GetxController {
  SplashController({
    required this.auth,
    required this.preferences,
    required this.session,
    this.delay = const Duration(seconds: 2),
  });

  final AuthRepository auth;
  final PreferencesService preferences;
  final SessionController session;

  /// Minimum time the branding stays visible.
  final Duration delay;

  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    // Start the work immediately; the delay only sets a minimum duration.
    final start = decideStart(auth: auth, preferences: preferences);
    await Future<void>.delayed(delay);
    final (destination, user) = await start;

    if (user != null) session.signedIn(user);
    await Get.offAllNamed<void>(switch (destination) {
      StartDestination.home => AppRoutes.home,
      StartDestination.login => AppRoutes.login,
      StartDestination.welcome => AppRoutes.welcome,
    });
  }
}
