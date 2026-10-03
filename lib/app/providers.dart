import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/core/network/dio_client.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/services/preferences_service.dart';
import 'package:new_app/core/services/storage_service.dart';
import 'package:new_app/data/datasources/auth_api.dart';
import 'package:new_app/data/datasources/onboarding_api.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/data/repositories/onboarding_repository.dart';
import 'package:new_app/features/session/session_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Core providers — the composition root. Every object is created lazily,
/// once, and can be swapped with `overrides` (tests, flavors).

/// Overridden in `main` once the async instance is ready.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPreferencesProvider in ProviderScope'),
);

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

final secureStoreProvider = Provider<SecureStore>((ref) => const PlatformSecureStore());

/// Tests override this with an instant backend; `null` = decide from config.
final mockBackendProvider = Provider<MockBackend?>((ref) => null);

final preferencesServiceProvider = Provider<PreferencesService>(
  (ref) => PreferencesService(ref.watch(sharedPreferencesProvider)),
);

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(secure: ref.watch(secureStoreProvider), prefs: ref.watch(sharedPreferencesProvider)),
);

final dioProvider = Provider<Dio>((ref) {
  final dio = DioClient.create(
    config: ref.watch(appConfigProvider),
    storage: ref.watch(storageServiceProvider),
    mockBackend: ref.watch(mockBackendProvider),
    onSessionExpired: () => ref.read(sessionProvider.notifier).expired(),
  );
  ref.onDispose(dio.close);
  return dio;
});

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(dioProvider)));

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(api: ref.watch(authApiProvider), storage: ref.watch(storageServiceProvider)),
);

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(OnboardingApi(ref.watch(dioProvider))),
);
