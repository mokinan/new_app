import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:new_app/app/app.dart';
import 'package:new_app/app/dependencies.dart';
import 'package:new_app/app/routes/app_routes.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/services/storage_service.dart';
import 'package:new_app/data/datasources/auth_api.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the real app (GetX DI, routes, bindings) against an instant mock
/// backend and in-memory storage.
class AppHarness {
  AppHarness(this.tester);

  final WidgetTester tester;
  final backend = MockBackend(latency: Duration.zero);
  late SharedPreferences prefs;

  Future<void> start({
    bool onboarded = false,
    bool signedIn = false,
    bool darkMode = false,
    String initialRoute = AppRoutes.splash,
  }) async {
    Get
      ..testMode = true
      ..reset();
    SharedPreferences.setMockInitialValues({'isOnboarded': onboarded, 'isDarkMode': darkMode});
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.runAsync(() async {
      prefs = await SharedPreferences.getInstance();
      await registerDependencies(
        config: const AppConfig(environment: AppEnvironment.development, splashDelay: Duration.zero),
        prefs: prefs,
        secureStore: InMemorySecureStore(),
        mockBackend: backend,
      );
      if (signedIn) {
        await Get.find<AuthRepository>().login(email: MockBackend.demoEmail, password: MockBackend.demoPassword);
      }
    });
    await tester.pumpWidget(App(initialRoute: initialRoute));
    await settle();
  }

  /// Lets async work (storage, mock HTTP) and navigation finish. The splash
  /// spinner never stops animating, so `pumpAndSettle` cannot be used there.
  Future<void> settle() async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  Future<void> tapText(String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.tap(find.text(text).last);
    await settle();
  }

  Future<void> enter(String key, String text) => tester.enterText(find.byKey(Key(key)), text);

  /// Replaces the stored refresh token with one the server will reject.
  Future<void> expireRefreshToken() => tester.runAsync(
    () => Get.find<StorageService>().saveTokens(
      accessToken: 'expired',
      refreshToken: 'revoked',
      expiresAt: DateTime(2000),
    ),
  );

  /// Any authenticated call; triggers the refresh flow on 401.
  Future<void> callProtectedEndpoint() async {
    await tester.runAsync(() async {
      try {
        await Get.find<AuthApi>().me();
      } on ApiException {
        // Expected: the session is over.
      }
    });
    await settle();
  }
}
