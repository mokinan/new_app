import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/core/services/storage_service.dart';
import 'package:new_app/data/datasources/auth_api.dart';
import 'package:new_app/data/models/auth_response_model.dart';
import 'package:new_app/data/models/user_model.dart';

/// Authentication use cases shared by every branch: talk to the API and
/// persist the session. State management only *exposes* the result.
class AuthRepository {
  const AuthRepository({required AuthApi api, required StorageService storage}) : _api = api, _storage = storage;

  final AuthApi _api;
  final StorageService _storage;

  /// Throws [ApiException] (e.g. 401 for wrong credentials).
  Future<UserModel> login({required String email, required String password}) async =>
      _persist(await _api.login(email: email, password: password));

  /// Throws [ApiException] (e.g. 422 with `fieldErrors` for a taken email).
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessName,
  }) async => _persist(
    await _api.register(name: name, email: email, password: password, phone: phone, businessName: businessName),
  );

  /// The signed-in user from the last session, or `null`.
  ///
  /// A session is restorable while a refresh token exists: an expired access
  /// token is renewed transparently by `AuthInterceptor` on the first call.
  Future<UserModel?> restoreSession() async {
    final user = UserModel.fromJsonString(_storage.getUserJson() ?? '');
    final refreshToken = await _storage.getRefreshToken();
    if (user == null || refreshToken == null) {
      await _storage.clearAll();
      return null;
    }
    return user;
  }

  /// Ends the session locally even if the server cannot be reached.
  Future<void> logout() async {
    try {
      await _api.logout();
    } on ApiException {
      // Best effort: local logout must never depend on the network.
    }
    await _storage.clearAll();
  }

  Future<UserModel> _persist(AuthResponseModel auth) async {
    await _storage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      expiresAt: auth.expiresAt,
    );
    await _storage.saveUserJson(auth.user.toJsonString());
    return auth.user;
  }
}
