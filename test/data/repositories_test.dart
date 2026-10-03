import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/data/datasources/onboarding_api.dart';
import 'package:new_app/data/models/onboarding_slide_model.dart';
import 'package:new_app/data/models/user_model.dart';
import 'package:new_app/data/repositories/onboarding_repository.dart';

import '../helpers/core_harness.dart';

class _MockOnboardingApi extends Mock implements OnboardingApi {}

void main() {
  late CoreHarness core;

  setUp(() async => core = await CoreHarness.create());

  group('AuthRepository', () {
    test('login persists tokens and the user', () async {
      final user = await core.authRepository.login(email: ' DEMO@app.com ', password: MockBackend.demoPassword);

      expect(user.businessName, 'متجر الأمين');
      expect(await core.storage.getAccessToken(), isNotNull);
      expect(UserModel.fromJsonString(core.storage.getUserJson()!)?.email, MockBackend.demoEmail);
    });

    test('wrong credentials surface as a 401 ApiException', () async {
      await expectLater(
        core.authRepository.login(email: MockBackend.demoEmail, password: 'nope'),
        throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.unauthorized)),
      );
      expect(await core.storage.getAccessToken(), isNull);
    });

    test('register signs the new user in; a taken email returns field errors', () async {
      final user = await core.authRepository.register(
        name: 'سارة',
        email: 'sara@shop.sa',
        password: 'Password1',
        businessName: 'متجر سارة',
      );
      expect(user.name, 'سارة');

      await expectLater(
        core.authRepository.register(name: 'x', email: MockBackend.demoEmail, password: 'Password1'),
        throwsA(isA<ApiException>().having((e) => e.fieldErrors['email'], 'email errors', isNotEmpty)),
      );
    });

    test('restoreSession returns the user while a refresh token exists', () async {
      expect(await core.authRepository.restoreSession(), isNull);
      await core.signIn();
      expect((await core.authRepository.restoreSession())?.email, MockBackend.demoEmail);
    });

    test('logout clears the session even when the server fails', () async {
      await core.signIn();
      await core.secure.write('access_token', 'stale');
      await core.authRepository.logout();
      expect(await core.authRepository.restoreSession(), isNull);
    });
  });

  group('OnboardingRepository', () {
    test('returns server slides sorted by order', () async {
      final slides = await core.onboardingRepository.getSlides();
      expect(slides.map((s) => s.order), [1, 2, 3]);
    });

    test('falls back to built-in slides on error or empty response', () async {
      final api = _MockOnboardingApi();
      when(api.getSlides).thenThrow(const ApiException(type: ApiErrorType.network, message: 'offline'));
      expect(await OnboardingRepository(api).getSlides(), OnboardingRepository.fallbackSlides);

      when(api.getSlides).thenAnswer((_) async => const <OnboardingSlideModel>[]);
      expect(await OnboardingRepository(api).getSlides(), OnboardingRepository.fallbackSlides);
    });
  });

  group('decideStart', () {
    test('first launch → welcome', () async {
      final (destination, user) = await decideStart(auth: core.authRepository, preferences: core.preferences);
      expect(destination, StartDestination.welcome);
      expect(user, isNull);
    });

    test('onboarded, signed out → login', () async {
      await core.preferences.setOnboarded(value: true);
      expect((await decideStart(auth: core.authRepository, preferences: core.preferences)).$1, StartDestination.login);
    });

    test('restorable session → home with the user', () async {
      await core.signIn();
      final (destination, user) = await decideStart(auth: core.authRepository, preferences: core.preferences);
      expect(destination, StartDestination.home);
      expect(user?.email, MockBackend.demoEmail);
    });
  });

  group('AppConfig', () {
    test('defaults to the mock environment', () {
      expect(AppConfig.fromEnvironment().environment, AppEnvironment.mock);
      expect(const AppConfig().useMockBackend, isTrue);
    });

    test('flags per environment', () {
      const prod = AppConfig(environment: AppEnvironment.production);
      expect(prod.baseUrl, 'https://api.yourapp.com/v1');
      expect(prod.showDebugBanner, isFalse);
      expect(prod.enableAnalytics, isTrue);
      expect(const AppConfig(environment: AppEnvironment.staging).enableCrashReport, isTrue);
    });
  });

  group('PreferencesService', () {
    test('defaults and persistence', () async {
      expect(core.preferences.isDarkMode, isFalse);
      expect(core.preferences.locale, 'ar');
      await core.preferences.setDarkMode(value: true);
      await core.preferences.setLocale('en');
      expect(core.preferences.isDarkMode, isTrue);
      expect(core.preferences.locale, 'en');
    });
  });

  group('UserModel', () {
    test('round-trips through JSON and tolerates garbage', () {
      const user = UserModel(id: '1', name: 'n', email: 'e@x.co', businessName: 'b');
      expect(UserModel.fromJsonString(user.toJsonString())?.businessName, 'b');
      expect(UserModel.fromJsonString('not json'), isNull);
      expect(user.copyWith(name: 'm').name, 'm');
    });
  });
}
