import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/core/config/app_config.dart';
import '../../helpers/test_helpers.dart';

void main() {
  setUp(setupGetX);

  group('AppConfig — baseUrl per environment', () {
    test('development returns dev URL', () {
      final config = AppConfig(environment: AppEnvironment.development);
      expect(config.baseUrl, contains('dev-api'));
    });

    test('staging returns staging URL', () {
      final config = AppConfig(environment: AppEnvironment.staging);
      expect(config.baseUrl, contains('staging-api'));
    });

    test('production returns prod URL', () {
      final config = AppConfig(environment: AppEnvironment.production);
      expect(config.baseUrl, isNot(contains('dev')));
      expect(config.baseUrl, isNot(contains('staging')));
    });
  });

  group('AppConfig — feature flags', () {
    test('analytics disabled in development', () {
      final config = AppConfig(environment: AppEnvironment.development);
      expect(config.enableAnalytics, isFalse);
    });

    test('analytics enabled in production', () {
      final config = AppConfig(environment: AppEnvironment.production);
      expect(config.enableAnalytics, isTrue);
    });

    test('debug banner shown only in development', () {
      expect(
        AppConfig(environment: AppEnvironment.development).showDebugBanner,
        isTrue,
      );
      expect(
        AppConfig(environment: AppEnvironment.production).showDebugBanner,
        isFalse,
      );
    });

    test('crash reporting disabled in development', () {
      expect(
        AppConfig(environment: AppEnvironment.development).enableCrashReport,
        isFalse,
      );
    });
  });

  group('AppConfig — reactive defaults', () {
    test('isDarkMode defaults to false', () {
      final config = setupAppConfig();
      expect(config.isDarkMode, isFalse);
    });

    test('locale defaults to en', () {
      final config = setupAppConfig();
      expect(config.locale, equals('en'));
    });

    test('isOnboarded defaults to false', () {
      final config = setupAppConfig();
      expect(config.isOnboarded, isFalse);
    });
  });

  group('AppConfig — timeouts', () {
    test('connect timeout is positive', () {
      final config = setupAppConfig();
      expect(config.connectTimeout, greaterThan(0));
    });

    test('receive timeout is positive', () {
      final config = setupAppConfig();
      expect(config.receiveTimeout, greaterThan(0));
    });
  });
}
