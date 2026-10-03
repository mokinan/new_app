import 'dart:async';

import 'package:dio/dio.dart';
import 'package:new_app/core/network/api_endpoints.dart';
import 'package:new_app/core/services/storage_service.dart';

/// Attaches the access token and refreshes it on 401.
///
/// Refresh is **single-flight**: while one refresh is running, other 401s
/// wait for it and then replay with the new token — refresh tokens usually
/// rotate, so a second concurrent refresh would fail and log the user out.
///
/// [onSessionExpired] is called only when the server rejects the refresh
/// token; each branch wires it to its own logout/navigation.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required StorageService storage,
    required void Function() onSessionExpired,
  }) : _dio = dio,
       _refreshDio = refreshDio,
       _storage = storage,
       _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final Dio _refreshDio;
  final StorageService _storage;
  final void Function() _onSessionExpired;

  Future<String?>? _refreshing;

  static const _retriedKey = 'auth_retried';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    final isAuthCall = request.path == ApiEndpoints.refreshToken || request.path == ApiEndpoints.login;
    if (!isUnauthorized || isAuthCall || request.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    final usedToken = (request.headers['Authorization'] as String?)?.replaceFirst('Bearer ', '');
    final current = await _storage.getAccessToken();
    // Another request already refreshed while this one was in flight.
    final token = current != null && current != usedToken
        ? current
        : await (_refreshing ??= _refresh().whenComplete(() => _refreshing = null));

    if (token == null) return handler.next(err);

    try {
      request
        ..headers['Authorization'] = 'Bearer $token'
        ..extra[_retriedKey] = true;
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Returns the new access token, or `null` if the session is over.
  Future<String?> _refresh() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      _expire();
      return null;
    }
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      final data = response.data!;
      final access = data['access_token'] as String;
      await _storage.saveTokens(
        accessToken: access,
        refreshToken: data['refresh_token'] as String,
        expiresAt: DateTime.now().add(Duration(seconds: data['expires_in'] as int? ?? 3600)),
      );
      return access;
    } on DioException catch (e) {
      // Only a definitive rejection ends the session; a network blip does not.
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) _expire();
      return null;
    }
  }

  void _expire() {
    unawaited(_storage.clearAll());
    _onSessionExpired();
  }
}
