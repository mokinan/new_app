import 'package:dio/dio.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/core/network/interceptors/auth_interceptor.dart';
import 'package:new_app/core/network/interceptors/error_interceptor.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/services/storage_service.dart';

/// Builds the app's [Dio]. Created once in each branch's composition root
/// and passed to the API classes — no global singleton, so tests build their
/// own.
abstract final class DioClient {
  static Dio create({
    required AppConfig config,
    required StorageService storage,
    required void Function() onSessionExpired,
    MockBackend? mockBackend,
  }) {
    BaseOptions options() => BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    );

    final mock = mockBackend ?? (config.useMockBackend ? MockBackend() : null);
    final refreshDio = Dio(options());
    final dio = Dio(options());
    if (mock != null) {
      // The mock plugs in at the adapter level, so every interceptor below
      // (auth, refresh, error mapping) runs exactly as against a real server.
      refreshDio.httpClientAdapter = mock.adapter;
      dio.httpClientAdapter = mock.adapter;
    }

    refreshDio.interceptors.add(ErrorInterceptor(log: config.logNetwork));
    dio.interceptors.addAll([
      AuthInterceptor(dio: dio, refreshDio: refreshDio, storage: storage, onSessionExpired: onSessionExpired),
      ErrorInterceptor(log: config.logNetwork),
    ]);
    return dio;
  }
}
