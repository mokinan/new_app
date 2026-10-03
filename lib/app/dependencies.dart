import 'package:dio/dio.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/core/network/dio_client.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/services/preferences_service.dart';
import 'package:new_app/core/services/storage_service.dart';
import 'package:new_app/data/datasources/auth_api.dart';
import 'package:new_app/data/datasources/onboarding_api.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/data/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Composition root: builds every framework-free object once.
///
/// The app hands these to `RepositoryProvider`s; tests build their own with
/// in-memory storage and an instant mock backend.
class AppDependencies {
  AppDependencies._({
    required this.config,
    required this.preferences,
    required this.storage,
    required this.dio,
    required this.authApi,
    required this.authRepository,
    required this.onboardingRepository,
  });

  static Future<AppDependencies> create({
    AppConfig? config,
    SharedPreferences? prefs,
    SecureStore? secureStore,
    MockBackend? mockBackend,
  }) async {
    final appConfig = config ?? AppConfig.fromEnvironment();
    final sharedPrefs = prefs ?? await SharedPreferences.getInstance();
    final storage = StorageService(secure: secureStore ?? const PlatformSecureStore(), prefs: sharedPrefs);

    late final AppDependencies deps;
    final dio = DioClient.create(
      config: appConfig,
      storage: storage,
      mockBackend: mockBackend,
      // The session cubit is created later, inside the widget tree.
      onSessionExpired: () => deps._onSessionExpired?.call(),
    );
    final authApi = AuthApi(dio);
    return deps = AppDependencies._(
      config: appConfig,
      preferences: PreferencesService(sharedPrefs),
      storage: storage,
      dio: dio,
      authApi: authApi,
      authRepository: AuthRepository(api: authApi, storage: storage),
      onboardingRepository: OnboardingRepository(OnboardingApi(dio)),
    );
  }

  final AppConfig config;
  final PreferencesService preferences;
  final StorageService storage;
  final Dio dio;
  final AuthApi authApi;
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;

  void Function()? _onSessionExpired;

  /// Connects `AuthInterceptor`'s expiry signal to the session cubit.
  set onSessionExpired(void Function() callback) => _onSessionExpired = callback;
}
