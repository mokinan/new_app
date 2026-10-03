import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:mocktail/mocktail.dart';
export 'mock_app_config.dart';

// ─── GetX Reset ───────────────────────────────────────────────
/// Call in setUp() to reset GetX state between tests.
void setupGetX() {
  Get.testMode = true;
  Get.reset();
  // Provide in-memory SharedPreferences so plugin channel calls don't fail
  SharedPreferences.setMockInitialValues({});
}

/// Puts a real AppConfig in GetX for tests that need it.
AppConfig setupAppConfig({
  AppEnvironment environment = AppEnvironment.development,
}) {
  final config = AppConfig(environment: environment);
  Get.put<AppConfig>(config, permanent: true);
  return config;
}

// ─── Widget Pump Helpers ──────────────────────────────────────
/// Wraps a widget in GetMaterialApp with the app theme for widget tests.
Widget testableWidget(Widget child) {
  return GetMaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    home: child,
  );
}

/// Pumps [child] inside the app theme at a given [screenSize].
///
/// Defaults to a standard mobile size (390×844) so that `ResponsiveBuilder`
/// always selects the mobile layout in tests unless you explicitly pass a
/// different size (e.g. `Size(768, 1024)` for tablet).
///
/// Pass [pump] to advance by a fixed duration (use for views that contain
/// infinite animations like `CircularProgressIndicator` where
/// `pumpAndSettle` would time out).
/// Omit [pump] to call `pumpAndSettle` — for finite animations only.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  Duration? pump,
  Size screenSize = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(screenSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(testableWidget(child));
  if (pump != null) {
    await tester.pump(pump);
  } else {
    await tester.pumpAndSettle();
  }
}

// ─── JSON Fixtures ────────────────────────────────────────────
/// Returns a decoded JSON map from test/fixtures/<filename>.json
/// Usage: `loadFixture('user_profile')`
Map<String, dynamic> mockJson(Map<String, dynamic> data) => data;
