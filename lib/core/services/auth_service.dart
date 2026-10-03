import 'package:get/get.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';
import 'storage_service.dart';

/// Single source of truth for authentication state.
/// Registered as permanent singleton in InitialBinding.
class AuthService extends GetxController {
  static AuthService get to => Get.find<AuthService>();

  // ─── Reactive state ───────────────────────────────────────
  final _user         = Rxn<UserModel>();
  final _isLoggedIn   = false.obs;

  UserModel? get user       => _user.value;
  bool       get isLoggedIn => _isLoggedIn.value;

  final _storage = StorageService.instance;

  // ─── Lifecycle ────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _rehydrate();
  }

  /// Loads persisted session from storage on cold start.
  Future<void> _rehydrate() async {
    await _storage.init();
    final userJson = _storage.getUserJson();
    if (userJson != null) {
      _user.value = UserModel.fromJsonString(userJson);
      _isLoggedIn.value = _user.value != null;
    }
  }

  // ─── Save auth after login / register ─────────────────────
  Future<void> saveAuth(AuthResponseModel auth) async {
    _user.value     = auth.user;
    _isLoggedIn.value = true;
    await Future.wait([
      _storage.saveTokens(
        accessToken:  auth.accessToken,
        refreshToken: auth.refreshToken,
        expiresAt:    auth.expiresAt,
      ),
      _storage.saveUserJson(auth.user.toJsonString()),
    ]);
  }

  /// Call after a token refresh to update only the tokens.
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) =>
      _storage.saveTokens(
        accessToken:  accessToken,
        refreshToken: refreshToken,
        expiresAt:    expiresAt,
      );

  // ─── Token state ──────────────────────────────────────────
  Future<bool> hasValidToken() async {
    final token   = await _storage.getAccessToken();
    final expiry  = await _storage.getTokenExpiry();
    if (token == null || expiry == null) return false;
    // Consider valid if more than 60 s remain
    return DateTime.now().isBefore(expiry.subtract(const Duration(seconds: 60)));
  }

  Future<String?> getAccessToken()  => _storage.getAccessToken();
  Future<String?> getRefreshToken() => _storage.getRefreshToken();

  // ─── Logout ───────────────────────────────────────────────
  Future<void> logout() async {
    _user.value       = null;
    _isLoggedIn.value = false;
    await _storage.clearAll();
  }
}
