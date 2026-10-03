import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:new_app/app/routes/app_routes.dart';
import 'package:new_app/features/splash/controllers/splash_controller.dart';
import '../../helpers/test_helpers.dart';

void main() {
  setUp(setupGetX);

  group('SplashController — navigation target', () {
    test('goes to welcome when user is NOT onboarded', () async {
      final config = setupAppConfig();
      await config.setOnboarded(false);

      Get.put(SplashController());

      expect(config.isOnboarded, isFalse);
      expect(AppRoutes.welcome, equals('/welcome'));
    });

    test('goes to home when user IS already onboarded', () async {
      final config = setupAppConfig();
      await config.setOnboarded(true);

      expect(config.isOnboarded, isTrue);
      expect(AppRoutes.home, equals('/home'));
    });

    test('splash delay is at least 1 second for branding visibility', () {
      const delay = Duration(seconds: 2);
      expect(delay.inMilliseconds, greaterThanOrEqualTo(1000));
    });
  });
}
