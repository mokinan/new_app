import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _buildDio();
    return _instance!;
  }

  static Dio _buildDio() {
    final config = AppConfig.to;

    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: Duration(milliseconds: config.connectTimeout),
        receiveTimeout: Duration(milliseconds: config.receiveTimeout),
        headers: {
          'Accept':       'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      if (config.showDebugBanner)
        LogInterceptor(
          requestBody:  true,
          responseBody: true,
          logPrint: (obj) => obj.toString(),
        ),
    ]);

    return dio;
  }

  static void reset() => _instance = null;
}
