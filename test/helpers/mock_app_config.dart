import 'package:mocktail/mocktail.dart';
import 'package:new_app/core/config/app_config.dart';

class MockAppConfig extends Mock implements AppConfig {}

class FakeAppConfig extends Fake implements AppConfig {
  @override
  AppEnvironment get environment => AppEnvironment.development;

  @override
  String get baseUrl => 'https://test-api.example.com/v1';

  @override
  int get connectTimeout => 5000;

  @override
  int get receiveTimeout => 5000;

  @override
  bool get isDarkMode => false;

  @override
  String get locale => 'en';

  @override
  bool get isOnboarded => false;

  @override
  bool get showDebugBanner => false;

  @override
  bool get enableAnalytics => false;

  @override
  bool get enableCrashReport => false;

  @override
  String get appVersion => '1.0.0';

  @override
  String get buildNumber => '1';

  @override
  String get appName => 'TestApp';
}
