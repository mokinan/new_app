import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central key–value store.
/// Sensitive data (tokens) → FlutterSecureStorage (Keychain / Keystore).
/// Non-sensitive data (user JSON, settings) → SharedPreferences.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  // ─── Secure keys ──────────────────────────────────────────
  static const _kAccessToken  = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kExpiresAt    = 'token_expires_at';

  // ─── Prefs keys ───────────────────────────────────────────
  static const _kUserJson     = 'user_json';

  // Note: encryptedSharedPreferences can hang on some emulators/devices;
  // the default AndroidOptions uses the Android Keystore which is more reliable.
  final _secure = const FlutterSecureStorage();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Tokens ───────────────────────────────────────────────
  Future<String?> getAccessToken()  => _secure.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => _secure.read(key: _kRefreshToken);

  Future<DateTime?> getTokenExpiry() async {
    final raw = await _secure.read(key: _kExpiresAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await Future.wait([
      _secure.write(key: _kAccessToken,  value: accessToken),
      _secure.write(key: _kRefreshToken, value: refreshToken),
      _secure.write(key: _kExpiresAt,    value: expiresAt.toIso8601String()),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _secure.delete(key: _kAccessToken),
      _secure.delete(key: _kRefreshToken),
      _secure.delete(key: _kExpiresAt),
    ]);
  }

  // ─── User ─────────────────────────────────────────────────
  String? getUserJson()        => _prefs?.getString(_kUserJson);
  Future<void> saveUserJson(String json) async =>
      _prefs?.setString(_kUserJson, json);
  Future<void> clearUser() async => _prefs?.remove(_kUserJson);

  // ─── Full wipe (logout) ───────────────────────────────────
  Future<void> clearAll() async {
    await clearTokens();
    await clearUser();
  }
}
