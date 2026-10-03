import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/app/app.dart';
import 'package:new_app/app/providers.dart';
import 'package:new_app/app/router.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the real app (providers, router, notifiers) against an instant mock
/// backend and in-memory storage — only the leaves are overridden.
class AppHarness {
  AppHarness(this.tester);

  final WidgetTester tester;
  final backend = MockBackend(latency: Duration.zero);
  late SharedPreferences prefs;

  /// The container behind the running app, for reaching any provider.
  ProviderContainer get container => ProviderScope.containerOf(tester.element(find.byType(App)));

  Future<void> start({
    bool onboarded = false,
    bool signedIn = false,
    bool darkMode = false,
    String initialRoute = AppRoutes.splash,
  }) async {
    SharedPreferences.setMockInitialValues({'isOnboarded': onboarded, 'isDarkMode': darkMode});
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final secureStore = InMemorySecureStore();
    late List<Override> overrides;
    await tester.runAsync(() async {
      prefs = await SharedPreferences.getInstance();
      overrides = [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(secureStore),
        mockBackendProvider.overrideWithValue(backend),
        appConfigProvider.overrideWithValue(
          const AppConfig(environment: AppEnvironment.development, splashDelay: Duration.zero),
        ),
        initialLocationProvider.overrideWithValue(initialRoute),
      ];
      if (signedIn) {
        // A previous app run that left tokens in storage.
        final previousRun = ProviderContainer(overrides: overrides);
        await previousRun
            .read(authRepositoryProvider)
            .login(email: MockBackend.demoEmail, password: MockBackend.demoPassword);
        previousRun.dispose();
      }
    });
    await tester.pumpWidget(ProviderScope(retry: (_, _) => null, overrides: overrides, child: const App()));
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
    () => container
        .read(storageServiceProvider)
        .saveTokens(accessToken: 'expired', refreshToken: 'revoked', expiresAt: DateTime(2000)),
  );

  /// Any authenticated call; triggers the refresh flow on 401.
  Future<void> callProtectedEndpoint() async {
    await tester.runAsync(() async {
      try {
        await container.read(authApiProvider).me();
      } on ApiException {
        // Expected: the session is over.
      }
    });
    await settle();
  }
}
