import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/data/models/user_model.dart';
import 'package:new_app/features/login/login_bloc.dart';
import 'package:new_app/features/register/register_bloc.dart';
import 'package:new_app/features/session/session_bloc.dart';
import 'package:new_app/features/settings/settings_bloc.dart';
import 'package:new_app/features/splash/splash_bloc.dart';
import 'package:new_app/features/welcome/welcome_bloc.dart';

import '../helpers/core_harness.dart';

/// Given events, expect states — against the real repositories and the
/// instant mock backend.
void main() {
  late CoreHarness core;
  late SessionBloc session;

  setUp(() async {
    core = await CoreHarness.create();
    session = SessionBloc(core.authRepository);
  });

  tearDown(() => session.close());

  /// Lets events forwarded to the session bloc be processed.
  Future<void> flush() => Future<void>.delayed(Duration.zero);

  group('LoginBloc', () {
    blocTest<LoginBloc, LoginState>(
      'LoginSubmitted: loading, then idle — and the session holds the user',
      build: () => LoginBloc(core.authRepository, session),
      act: (b) => b.add(const LoginSubmitted(email: MockBackend.demoEmail, password: MockBackend.demoPassword)),
      wait: const Duration(milliseconds: 100),
      expect: () => [const LoginState(isLoading: true), const LoginState()],
      verify: (_) async {
        await flush();
        expect(session.state.user?.email, MockBackend.demoEmail);
      },
    );

    blocTest<LoginBloc, LoginState>(
      'wrong password: loading, then the server message',
      build: () => LoginBloc(core.authRepository, session),
      act: (b) => b.add(const LoginSubmitted(email: MockBackend.demoEmail, password: 'nope')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const LoginState(isLoading: true),
        const LoginState(error: 'البريد الإلكتروني أو كلمة المرور غير صحيحة.'),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'droppable: a second submit while loading is ignored',
      build: () => LoginBloc(core.authRepository, session),
      act: (b) => b
        ..add(const LoginSubmitted(email: MockBackend.demoEmail, password: MockBackend.demoPassword))
        ..add(const LoginSubmitted(email: MockBackend.demoEmail, password: MockBackend.demoPassword)),
      wait: const Duration(milliseconds: 100),
      expect: () => [const LoginState(isLoading: true), const LoginState()],
    );
  });

  group('RegisterBloc', () {
    blocTest<RegisterBloc, RegisterState>(
      'tracks password strength',
      build: () => RegisterBloc(core.authRepository, session),
      act: (b) => b
        ..add(const RegisterPasswordChanged('abcdefgh'))
        ..add(const RegisterPasswordChanged('Abcdefg1!')),
      expect: () => [const RegisterState(passwordStrength: 1), const RegisterState(passwordStrength: 4)],
    );

    blocTest<RegisterBloc, RegisterState>(
      'a taken email becomes a field error, cleared when the email is edited',
      build: () => RegisterBloc(core.authRepository, session),
      act: (b) async {
        b.add(
          const RegisterSubmitted(
            businessName: 'b',
            ownerName: 'o',
            email: MockBackend.demoEmail,
            password: 'Password1',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        b.add(const RegisterEmailChanged());
      },
      skip: 1,
      expect: () => [
        isA<RegisterState>().having((s) => s.fieldErrors['email'], 'email error', 'هذا البريد مسجل مسبقًا.'),
        isA<RegisterState>().having((s) => s.fieldErrors, 'field errors', isEmpty),
      ],
    );
  });

  group('SessionBloc', () {
    blocTest<SessionBloc, SessionState>(
      'logout clears the user and storage',
      setUp: () => core.signIn(),
      build: () => SessionBloc(core.authRepository),
      seed: () => const SessionState(UserModel(id: '1', name: 'n', email: 'e@x.co')),
      act: (b) => b.add(const SessionLogoutRequested()),
      wait: const Duration(milliseconds: 100),
      expect: () => [const SessionState()],
      verify: (_) async => expect(await core.authRepository.restoreSession(), isNull),
    );

    blocTest<SessionBloc, SessionState>(
      'expiry signs the user out',
      build: () => SessionBloc(core.authRepository),
      seed: () => const SessionState(UserModel(id: '1', name: 'n', email: 'e@x.co')),
      act: (b) => b.add(const SessionExpired()),
      expect: () => [const SessionState()],
    );
  });

  group('SettingsBloc', () {
    blocTest<SettingsBloc, SettingsState>(
      'toggles dark mode and persists it',
      build: () => SettingsBloc(core.preferences),
      act: (b) => b.add(const SettingsDarkModeToggled()),
      expect: () => [const SettingsState(isDarkMode: true, locale: Locale('ar'))],
      verify: (_) => expect(core.preferences.isDarkMode, isTrue),
    );
  });

  group('WelcomeBloc', () {
    blocTest<WelcomeBloc, WelcomeState>(
      'loads slides, then finishing marks onboarding complete',
      build: () => WelcomeBloc(core.onboardingRepository, core.preferences),
      // Bloc handles events concurrently by default: wait for each step.
      act: (b) async {
        b.add(const WelcomeStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        b.add(const WelcomePageChanged(2));
        b.add(const WelcomeFinished());
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<WelcomeState>().having((s) => s.slides.length, 'slides', 3),
        isA<WelcomeState>().having((s) => s.isLastPage, 'last page', true),
        isA<WelcomeState>().having((s) => s.finished, 'finished', true),
      ],
      verify: (_) => expect(core.preferences.isOnboarded, isTrue),
    );
  });

  group('SplashBloc', () {
    SplashBloc build() =>
        SplashBloc(auth: core.authRepository, preferences: core.preferences, session: session, delay: Duration.zero);

    blocTest<SplashBloc, StartDestination?>(
      'first launch → welcome',
      build: build,
      act: (b) => b.add(const SplashStarted()),
      expect: () => [StartDestination.welcome],
    );

    blocTest<SplashBloc, StartDestination?>(
      'restored session → home, and the session is populated',
      setUp: () => core.signIn(),
      build: build,
      act: (b) => b.add(const SplashStarted()),
      expect: () => [StartDestination.home],
      verify: (_) async {
        await flush();
        expect(session.state.isLoggedIn, isTrue);
      },
    );
  });
}
