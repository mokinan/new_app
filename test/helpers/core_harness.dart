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

/// The real core (Dio + interceptors + repositories) wired to an instant
/// mock backend and in-memory storage. Shared by every branch's tests.
class CoreHarness {
  CoreHarness._(this.prefs, this.preferences);

  static Future<CoreHarness> create({Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues(prefs);
    final shared = await SharedPreferences.getInstance();
    return CoreHarness._(shared, PreferencesService(shared));
  }

  final SharedPreferences prefs;
  final PreferencesService preferences;
  final secure = InMemorySecureStore();
  final backend = MockBackend(latency: Duration.zero);
  int sessionExpiredCount = 0;

  late final storage = StorageService(secure: secure, prefs: prefs);
  late final Dio dio = DioClient.create(
    config: const AppConfig(environment: AppEnvironment.development),
    storage: storage,
    onSessionExpired: () => sessionExpiredCount++,
    mockBackend: backend,
  );
  late final authRepository = AuthRepository(api: AuthApi(dio), storage: storage);
  late final onboardingRepository = OnboardingRepository(OnboardingApi(dio));

  /// Signs in the demo user directly through the repository.
  Future<void> signIn() => authRepository.login(email: MockBackend.demoEmail, password: MockBackend.demoPassword);
}
