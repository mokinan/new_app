import 'package:get/get.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/core/network/dio_client.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/services/preferences_service.dart';
import 'package:new_app/core/services/storage_service.dart';
import 'package:new_app/data/datasources/auth_api.dart';
import 'package:new_app/data/datasources/onboarding_api.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/data/repositories/onboarding_repository.dart';
import 'package:new_app/features/session/session_controller.dart';
import 'package:new_app/features/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Composition root: registers app-wide singletons with GetX.
///
/// Feature controllers are registered by each route's `Binding`, so they are
/// created when the page opens and disposed when it closes.
/// Tests call this with in-memory storage and an instant mock backend.
Future<void> registerDependencies({
  AppConfig? config,
  SharedPreferences? prefs,
  SecureStore? secureStore,
  MockBackend? mockBackend,
}) async {
  final appConfig = config ?? AppConfig.fromEnvironment();
  final sharedPrefs = prefs ?? await SharedPreferences.getInstance();
  final storage = StorageService(secure: secureStore ?? const PlatformSecureStore(), prefs: sharedPrefs);

  final dio = DioClient.create(
    config: appConfig,
    storage: storage,
    mockBackend: mockBackend,
    // Resolved lazily: the session controller is registered below.
    onSessionExpired: () => Get.find<SessionController>().onSessionExpired(),
  );

  Get
    ..put(appConfig, permanent: true)
    ..put(PreferencesService(sharedPrefs), permanent: true)
    ..put(storage, permanent: true)
    ..put(dio, permanent: true)
    ..put(AuthApi(dio), permanent: true)
    ..put(AuthRepository(api: Get.find(), storage: storage), permanent: true)
    ..put(OnboardingRepository(OnboardingApi(dio)), permanent: true)
    ..put(SettingsController(Get.find()), permanent: true)
    ..put(SessionController(Get.find()), permanent: true);
}
