import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/data/models/user_model.dart';
import 'package:new_app/features/login/login_cubit.dart';
import 'package:new_app/features/register/register_cubit.dart';
import 'package:new_app/features/session/session_cubit.dart';
import 'package:new_app/features/settings/settings_cubit.dart';
import 'package:new_app/features/splash/splash_cubit.dart';
import 'package:new_app/features/welcome/welcome_cubit.dart';

import '../helpers/core_harness.dart';

/// Unit tests for each cubit, against the real repositories and the
/// instant mock backend.
void main() {
  late CoreHarness core;
  late SessionCubit session;

  setUp(() async {
    core = await CoreHarness.create();
    session = SessionCubit(core.authRepository);
  });

  tearDown(() => session.close());

  group('LoginCubit', () {
    blocTest<LoginCubit, LoginState>(
      'signs in: loading, then idle — and the session holds the user',
      build: () => LoginCubit(core.authRepository, session),
      act: (c) => c.submit(email: MockBackend.demoEmail, password: MockBackend.demoPassword),
      expect: () => [const LoginState(isLoading: true), const LoginState()],
      verify: (_) => expect(session.state.user?.email, MockBackend.demoEmail),
    );

    blocTest<LoginCubit, LoginState>(
      'wrong password: loading, then the server message',
      build: () => LoginCubit(core.authRepository, session),
      act: (c) => c.submit(email: MockBackend.demoEmail, password: 'nope'),
      expect: () => [
        const LoginState(isLoading: true),
        const LoginState(error: 'البريد الإلكتروني أو كلمة المرور غير صحيحة.'),
      ],
      verify: (_) => expect(session.state.isLoggedIn, isFalse),
    );

    blocTest<LoginCubit, LoginState>(
      'ignores a second submit while loading',
      build: () => LoginCubit(core.authRepository, session),
      act: (c) async {
        final first = c.submit(email: MockBackend.demoEmail, password: MockBackend.demoPassword);
        await c.submit(email: MockBackend.demoEmail, password: MockBackend.demoPassword);
        await first;
      },
      expect: () => [const LoginState(isLoading: true), const LoginState()],
    );
  });

  group('RegisterCubit', () {
    blocTest<RegisterCubit, RegisterState>(
      'tracks password strength',
      build: () => RegisterCubit(core.authRepository, session),
      act: (c) => c
        ..passwordChanged('abcdefgh')
        ..passwordChanged('Abcdefg1!'),
      expect: () => [const RegisterState(passwordStrength: 1), const RegisterState(passwordStrength: 4)],
    );

    blocTest<RegisterCubit, RegisterState>(
      'a taken email becomes a field error',
      build: () => RegisterCubit(core.authRepository, session),
      act: (c) => c.submit(businessName: 'b', ownerName: 'o', email: MockBackend.demoEmail, password: 'Password1'),
      skip: 1,
      expect: () => [
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.fieldErrors['email'], 'email error', 'هذا البريد مسجل مسبقًا.'),
      ],
    );
  });

  group('SessionCubit', () {
    test('logout clears the user and storage', () async {
      await core.signIn();
      session.signedIn((await core.authRepository.restoreSession())!);
      await session.logout();
      expect(session.state.isLoggedIn, isFalse);
      expect(await core.authRepository.restoreSession(), isNull);
    });

    blocTest<SessionCubit, SessionState>(
      'expiry signs the user out',
      build: () => SessionCubit(core.authRepository),
      seed: () => const SessionState(UserModel(id: '1', name: 'n', email: 'e@x.co')),
      act: (c) => c.expired(),
      expect: () => [const SessionState()],
    );
  });

  group('SettingsCubit', () {
    blocTest<SettingsCubit, SettingsState>(
      'toggles dark mode and persists it',
      build: () => SettingsCubit(core.preferences),
      act: (c) => c.toggleDarkMode(),
      expect: () => [const SettingsState(isDarkMode: true, locale: Locale('ar'))],
      verify: (_) => expect(core.preferences.isDarkMode, isTrue),
    );
  });

  group('WelcomeCubit', () {
    blocTest<WelcomeCubit, WelcomeState>(
      'loads slides, then finishing marks onboarding complete',
      build: () => WelcomeCubit(core.onboardingRepository, SettingsCubit(core.preferences)),
      act: (c) async {
        await c.load();
        c.pageChanged(2);
        await c.finish();
      },
      expect: () => [
        isA<WelcomeState>().having((s) => s.slides.length, 'slides', 3).having((s) => s.isLoading, 'loading', false),
        isA<WelcomeState>().having((s) => s.isLastPage, 'last page', true),
        isA<WelcomeState>().having((s) => s.finished, 'finished', true),
      ],
      verify: (_) => expect(core.preferences.isOnboarded, isTrue),
    );
  });

  group('SplashCubit', () {
    SplashCubit build() =>
        SplashCubit(auth: core.authRepository, preferences: core.preferences, session: session, delay: Duration.zero);

    blocTest<SplashCubit, StartDestination?>(
      'first launch → welcome',
      build: build,
      act: (c) => c.start(),
      expect: () => [StartDestination.welcome],
    );

    blocTest<SplashCubit, StartDestination?>(
      'restored session → home, and the session is populated',
      setUp: () => core.signIn(),
      build: build,
      act: (c) => c.start(),
      expect: () => [StartDestination.home],
      verify: (_) => expect(session.state.isLoggedIn, isTrue),
    );
  });
}
