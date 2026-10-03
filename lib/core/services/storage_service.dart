import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal secure key–value contract, so storage can be faked in tests.
abstract interface class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Keychain (iOS) / Keystore (Android).
class PlatformSecureStore implements SecureStore {
  const PlatformSecureStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// In-memory store for tests.
class InMemorySecureStore implements SecureStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// Session persistence.
/// Sensitive data (tokens) → [SecureStore]. Non-sensitive data (user JSON) →
/// SharedPreferences.
class StorageService {
  StorageService({required SecureStore secure, required SharedPreferences prefs}) : _secure = secure, _prefs = prefs;

  // ─── Secure keys ──────────────────────────────────────────
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kExpiresAt = 'token_expires_at';

  // ─── Prefs keys ───────────────────────────────────────────
  static const _kUserJson = 'user_json';

  final SecureStore _secure;
  final SharedPreferences _prefs;

  // ─── Tokens ───────────────────────────────────────────────
  Future<String?> getAccessToken() => _secure.read(_kAccessToken);
  Future<String?> getRefreshToken() => _secure.read(_kRefreshToken);

  Future<DateTime?> getTokenExpiry() async {
    final raw = await _secure.read(_kExpiresAt);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> saveTokens({required String accessToken, required String refreshToken, required DateTime expiresAt}) =>
      Future.wait([
        _secure.write(_kAccessToken, accessToken),
        _secure.write(_kRefreshToken, refreshToken),
        _secure.write(_kExpiresAt, expiresAt.toIso8601String()),
      ]);

  Future<void> clearTokens() =>
      Future.wait([_secure.delete(_kAccessToken), _secure.delete(_kRefreshToken), _secure.delete(_kExpiresAt)]);

  // ─── User ─────────────────────────────────────────────────
  String? getUserJson() => _prefs.getString(_kUserJson);
  Future<void> saveUserJson(String json) => _prefs.setString(_kUserJson, json);
  Future<void> clearUser() => _prefs.remove(_kUserJson);

  // ─── Full wipe (logout) ───────────────────────────────────
  Future<void> clearAll() async {
    await clearTokens();
    await clearUser();
  }
}
