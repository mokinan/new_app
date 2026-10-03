import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/app/providers.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/services/storage_service.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/data/models/user_model.dart';
import 'package:new_app/features/login/login_notifier.dart';
import 'package:new_app/features/register/register_notifier.dart';
import 'package:new_app/features/session/session_notifier.dart';
import 'package:new_app/features/settings/settings_notifier.dart';
import 'package:new_app/features/splash/splash_provider.dart';
import 'package:new_app/features/welcome/welcome_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Unit tests for each notifier: a real `ProviderContainer` with only the
/// leaves overridden (preferences, secure storage, instant mock backend).
void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(InMemorySecureStore()),
        mockBackendProvider.overrideWithValue(MockBackend(latency: Duration.zero)),
        appConfigProvider.overrideWithValue(
          const AppConfig(environment: AppEnvironment.development, splashDelay: Duration.zero),
        ),
      ],
    );
  });

  /// Keeps an (autoDispose) provider alive and records every state it emits.
  List<T> record<T>(ProviderListenable<T> provider) {
    final states = <T>[];
    container.listen(provider, (_, next) => states.add(next));
    return states;
  }

  Future<void> signIn() =>
      container.read(authRepositoryProvider).login(email: MockBackend.demoEmail, password: MockBackend.demoPassword);

  group('LoginNotifier', () {
    test('signs in: loading, then idle — and the session holds the user', () async {
      final states = record(loginProvider);
      await container
          .read(loginProvider.notifier)
          .submit(email: MockBackend.demoEmail, password: MockBackend.demoPassword);
      expect(states.map((s) => (s.isLoading, s.error)), [(true, null), (false, null)]);
      expect(container.read(sessionProvider)?.email, MockBackend.demoEmail);
    });

    test('wrong password: loading, then the server message', () async {
      final states = record(loginProvider);
      await container.read(loginProvider.notifier).submit(email: MockBackend.demoEmail, password: 'nope');
      expect(states.map((s) => (s.isLoading, s.error)), [
        (true, null),
        (false, 'البريد الإلكتروني أو كلمة المرور غير صحيحة.'),
      ]);
      expect(container.read(sessionProvider), isNull);
    });

    test('ignores a second submit while loading', () async {
      final states = record(loginProvider);
      final notifier = container.read(loginProvider.notifier);
      final first = notifier.submit(email: MockBackend.demoEmail, password: MockBackend.demoPassword);
      await notifier.submit(email: MockBackend.demoEmail, password: MockBackend.demoPassword);
      await first;
      expect(states.map((s) => s.isLoading), [true, false]);
    });
  });

  group('RegisterNotifier', () {
    test('tracks password strength', () {
      final states = record(registerProvider);
      container.read(registerProvider.notifier)
        ..passwordChanged('abcdefgh')
        ..passwordChanged('Abcdefg1!');
      expect(states.map((s) => s.passwordStrength), [1, 4]);
    });

    test('a taken email becomes a field error, cleared when the email changes', () async {
      record(registerProvider);
      final notifier = container.read(registerProvider.notifier);
      await notifier.submit(businessName: 'b', ownerName: 'o', email: MockBackend.demoEmail, password: 'Password1');
      final state = container.read(registerProvider);
      expect(state.isLoading, isFalse);
      expect(state.fieldErrors['email'], 'هذا البريد مسجل مسبقًا.');

      notifier.emailChanged();
      expect(container.read(registerProvider).fieldErrors, isEmpty);
    });
  });

  group('SessionNotifier', () {
    test('logout clears the user and storage', () async {
      await signIn();
      final auth = container.read(authRepositoryProvider);
      container.read(sessionProvider.notifier).signedIn((await auth.restoreSession())!);
      await container.read(sessionProvider.notifier).logout();
      expect(container.read(sessionProvider), isNull);
      expect(await auth.restoreSession(), isNull);
    });

    test('a rejected refresh token signs the user out (interceptor → provider)', () async {
      await signIn();
      container.read(sessionProvider.notifier).signedIn(const UserModel(id: '1', name: 'n', email: 'e@x.co'));
      await container
          .read(storageServiceProvider)
          .saveTokens(accessToken: 'expired', refreshToken: 'revoked', expiresAt: DateTime(2000));
      await expectLater(container.read(authApiProvider).me(), throwsA(isA<ApiException>()));
      expect(container.read(sessionProvider), isNull);
    });
  });

  group('SettingsNotifier', () {
    test('toggles dark mode and persists it', () async {
      await container.read(settingsProvider.notifier).toggleDarkMode();
      expect(container.read(settingsProvider).isDarkMode, isTrue);
      expect(container.read(preferencesServiceProvider).isDarkMode, isTrue);
    });
  });

  group('WelcomeNotifier', () {
    test('loads slides, then finishing marks onboarding complete', () async {
      record(welcomeProvider);
      await pumpEventQueue();
      expect(container.read(welcomeProvider).isLoading, isFalse);
      expect(container.read(welcomeProvider).slides, hasLength(3));

      final notifier = container.read(welcomeProvider.notifier)..pageChanged(2);
      expect(container.read(welcomeProvider).isLastPage, isTrue);
      await notifier.finish();
      expect(container.read(welcomeProvider).finished, isTrue);
      expect(container.read(preferencesServiceProvider).isOnboarded, isTrue);
    });
  });

  group('startDestinationProvider', () {
    test('first launch → welcome', () async {
      record(startDestinationProvider);
      expect(await container.read(startDestinationProvider.future), StartDestination.welcome);
    });

    test('restored session → home, and the session is populated', () async {
      await signIn();
      record(startDestinationProvider);
      expect(await container.read(startDestinationProvider.future), StartDestination.home);
      expect(container.read(sessionProvider), isNotNull);
    });
  });
}
