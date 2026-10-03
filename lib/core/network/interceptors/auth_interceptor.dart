import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../api_endpoints.dart';
import '../../../app/routes/app_routes.dart';

class AuthInterceptor extends Interceptor {
  // ─── Refresh lock ─────────────────────────────────────────
  // Prevents multiple simultaneous refresh calls.
  // All 401 requests while a refresh is in-flight are queued and retried.
  bool _isRefreshing = false;
  final _queue = <({
    RequestOptions options,
    ErrorInterceptorHandler handler
  })>[];

  final _storage = StorageService.instance;

  // ─── Attach token ─────────────────────────────────────────
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ─── Handle 401 → refresh ─────────────────────────────────
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final isRefreshCall =
        err.requestOptions.path.contains(ApiEndpoints.refreshToken);

    if (!is401 || isRefreshCall) {
      handler.next(err);
      return;
    }

    // Another refresh is already in-flight — queue this request
    if (_isRefreshing) {
      _queue.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null) {
        await _forceLogout();
        handler.next(err);
        return;
      }

      // Use a plain Dio (no interceptors) to avoid loops
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.to.baseUrl,
          headers: {'Accept': 'application/json'},
        ),
      );

      final refreshResponse = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final data        = refreshResponse.data as Map<String, dynamic>;
      final newAccess   = data['access_token'] as String;
      final newRefresh  = data['refresh_token'] as String;
      final expiresIn   = data['expires_in'] as int? ?? 3600;
      final newExpiry   = DateTime.now().add(Duration(seconds: expiresIn));

      // Persist new tokens
      await AuthService.to.updateTokens(
        accessToken:  newAccess,
        refreshToken: newRefresh,
        expiresAt:    newExpiry,
      );

      // Retry original request
      final retried = await _retry(err.requestOptions, newAccess);
      handler.resolve(retried);

      // Drain the queue
      for (final req in _queue) {
        try {
          final retriedQueued = await _retry(req.options, newAccess);
          req.handler.resolve(retriedQueued);
        } catch (e) {
          req.handler.next(err);
        }
      }
    } catch (_) {
      // Refresh failed — clear everything and send to login
      for (final req in _queue) {
        req.handler.next(err);
      }
      await _forceLogout();
      handler.next(err);
    } finally {
      _queue.clear();
      _isRefreshing = false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────
  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String newToken,
  ) {
    final opts = options.copyWith(
      headers: {
        ...options.headers,
        'Authorization': 'Bearer $newToken',
      },
    );
    return Dio().fetch(opts);
  }

  Future<void> _forceLogout() async {
    await AuthService.to.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
