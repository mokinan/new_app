import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/data/models/user_model.dart';
import 'package:new_app/features/login/login_notifier.dart';
import 'package:new_app/features/register/register_notifier.dart';
import 'package:new_app/features/session/session_notifier.dart';
import 'package:new_app/features/settings/settings_notifier.dart';
import 'package:new_app/features/splash/splash_notifier.dart';
import 'package:new_app/features/welcome/welcome_notifier.dart';

import '../helpers/core_harness.dart';

/// Unit tests for each ChangeNotifier, against the real repositories and the
/// instant mock backend.
void main() {
  late CoreHarness core;
  late SessionNotifier session;

  setUp(() async {
    core = await CoreHarness.create();
    session = SessionNotifier(core.authRepository);
  });

  /// Records the value of [read] on every notification.
  List<T> track<T>(LoginNotifier n, T Function() read) {
    final values = <T>[];
    n.addListener(() => values.add(read()));
    return values;
  }

  group('LoginNotifier', () {
    test('signs in: loading, then idle — and the session holds the user', () async {
      final login = LoginNotifier(core.authRepository, session);
      final loading = track(login, () => login.isLoading);

      await login.submit(email: MockBackend.demoEmail, password: MockBackend.demoPassword);

      expect(loading, [true, false]);
      expect(login.error, isNull);
      expect(session.user?.email, MockBackend.demoEmail);
    });

    test('wrong password shows the server message', () async {
      final login = LoginNotifier(core.authRepository, session);
      await login.submit(email: MockBackend.demoEmail, password: 'nope');
      expect(login.error, 'البريد الإلكتروني أو كلمة المرور غير صحيحة.');
      expect(session.isLoggedIn, isFalse);
    });

    test('ignores a second submit while loading', () async {
      final login = LoginNotifier(core.authRepository, session);
      final loading = track(login, () => login.isLoading);
      final first = login.submit(email: MockBackend.demoEmail, password: MockBackend.demoPassword);
      await login.submit(email: MockBackend.demoEmail, password: MockBackend.demoPassword);
      await first;
      expect(loading, [true, false]);
    });

    test('does not throw if disposed while a request is in flight', () async {
      final login = LoginNotifier(core.authRepository, session);
      final pending = login.submit(email: MockBackend.demoEmail, password: MockBackend.demoPassword);
      login.dispose();
      await expectLater(pending, completes);
    });
  });

  group('RegisterNotifier', () {
    test('tracks password strength', () {
      final register = RegisterNotifier(core.authRepository, session)..passwordChanged('Abcdefg1!');
      expect(register.passwordStrength, 4);
    });

    test('a taken email becomes a field error, cleared when edited', () async {
      final register = RegisterNotifier(core.authRepository, session);
      await register.submit(businessName: 'b', ownerName: 'o', email: MockBackend.demoEmail, password: 'Password1');
      expect(register.fieldErrors['email'], 'هذا البريد مسجل مسبقًا.');
      register.emailChanged();
      expect(register.fieldErrors, isEmpty);
    });
  });

  group('SessionNotifier', () {
    test('logout clears the user and storage', () async {
      await core.signIn();
      session.signedIn((await core.authRepository.restoreSession())!);
      await session.logout();
      expect(session.isLoggedIn, isFalse);
      expect(await core.authRepository.restoreSession(), isNull);
    });

    test('expiry signs the user out and notifies the router', () {
      var notified = 0;
      session
        ..signedIn(const UserModel(id: '1', name: 'n', email: 'e@x.co'))
        ..addListener(() => notified++)
        ..expired();
      expect(session.isLoggedIn, isFalse);
      expect(notified, 1);
    });
  });

  test('SettingsNotifier toggles dark mode and persists it', () async {
    final settings = SettingsNotifier(core.preferences);
    await settings.toggleDarkMode();
    expect(settings.isDarkMode, isTrue);
    expect(core.preferences.isDarkMode, isTrue);
  });

  test('WelcomeNotifier loads slides and finishing marks onboarding complete', () async {
    final welcome = WelcomeNotifier(core.onboardingRepository, SettingsNotifier(core.preferences));
    await welcome.load();
    expect(welcome.slides, hasLength(3));
    welcome.pageChanged(2);
    expect(welcome.isLastPage, isTrue);
    await welcome.finish();
    expect(welcome.finished, isTrue);
    expect(core.preferences.isOnboarded, isTrue);
  });

  group('SplashNotifier', () {
    SplashNotifier build() => SplashNotifier(
      auth: core.authRepository,
      preferences: core.preferences,
      session: session,
      delay: Duration.zero,
    );

    test('first launch → welcome', () async {
      final splash = build();
      await splash.start();
      expect(splash.destination, StartDestination.welcome);
    });

    test('restored session → home, and the session is populated', () async {
      await core.signIn();
      final splash = build();
      await splash.start();
      expect(splash.destination, StartDestination.home);
      expect(session.isLoggedIn, isTrue);
    });
  });
}
