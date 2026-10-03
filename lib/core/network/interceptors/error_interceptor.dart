import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:logger/logger.dart';

/// Central API error & success handler.
/// Attach to Dio interceptors — handles all HTTP status codes cleanly.
class ErrorInterceptor extends Interceptor {
  final _log = Logger(
    printer: PrettyPrinter(methodCount: 0, dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart),
  );

  // ─── Success ──────────────────────────────────────────────
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log.i('[${response.statusCode}] ${response.requestOptions.path}');
    handler.next(response);
  }

  // ─── Errors ───────────────────────────────────────────────
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = _parse(err);
    _log.e(
      '[${apiError.statusCode}] ${err.requestOptions.path}\n${apiError.message}',
      error: err,
    );
    _showSnackbar(apiError);
    handler.next(err);
  }

  // ─── Parse ────────────────────────────────────────────────
  ApiError _parse(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return ApiError(
          statusCode: 0,
          message: 'Connection timed out. Please check your network.',
          type: ApiErrorType.timeout,
        );
      case DioExceptionType.receiveTimeout:
        return ApiError(
          statusCode: 0,
          message: 'Server took too long to respond. Try again.',
          type: ApiErrorType.timeout,
        );
      case DioExceptionType.sendTimeout:
        return ApiError(
          statusCode: 0,
          message: 'Request timed out while sending. Try again.',
          type: ApiErrorType.timeout,
        );
      case DioExceptionType.connectionError:
        return ApiError(
          statusCode: 0,
          message: 'No internet connection.',
          type: ApiErrorType.network,
        );
      case DioExceptionType.cancel:
        return ApiError(
          statusCode: 0,
          message: 'Request was cancelled.',
          type: ApiErrorType.cancelled,
        );
      case DioExceptionType.badResponse:
        return _parseHttpStatus(err);
      default:
        return ApiError(
          statusCode: 0,
          message: 'An unexpected error occurred.',
          type: ApiErrorType.unknown,
        );
    }
  }

  ApiError _parseHttpStatus(DioException err) {
    final code = err.response?.statusCode ?? 0;
    final body = err.response?.data;
    final serverMsg = body is Map ? body['message'] as String? : null;

    final (message, type) = switch (code) {
      // 4xx Client errors
      400 => ('Invalid request. Please check your input.', ApiErrorType.badRequest),
      401 => ('Session expired. Please log in again.',     ApiErrorType.unauthorized),
      403 => ('You don\'t have permission to do this.',   ApiErrorType.forbidden),
      404 => ('The requested resource was not found.',    ApiErrorType.notFound),
      408 => ('Request timed out. Try again.',            ApiErrorType.timeout),
      409 => ('A conflict occurred. Please try again.',   ApiErrorType.conflict),
      410 => ('This resource no longer exists.',          ApiErrorType.gone),
      422 => ('Validation failed. Check your data.',      ApiErrorType.validation),
      429 => ('Too many requests. Please slow down.',     ApiErrorType.rateLimited),
      // 5xx Server errors
      500 => ('Server error. We\'re working on it.',      ApiErrorType.serverError),
      501 => ('Feature not supported by the server.',     ApiErrorType.serverError),
      502 => ('Bad gateway. Please try again later.',     ApiErrorType.serverError),
      503 => ('Service is temporarily unavailable.',      ApiErrorType.serverUnavailable),
      504 => ('Gateway timed out. Try again later.',      ApiErrorType.timeout),
      _   => ('Something went wrong ($code).',            ApiErrorType.unknown),
    };

    return ApiError(
      statusCode: code,
      message: serverMsg ?? message,
      type: type,
    );
  }

  // ─── Snackbar ─────────────────────────────────────────────
  void _showSnackbar(ApiError error) {
    if (error.type == ApiErrorType.cancelled) return;
    // Guard: no-op when Flutter binding isn't ready (unit tests / isolates).
    // Accessing Get.context itself throws if WidgetsBinding is uninitialised,
    // so we catch rather than check.
    try {
      if (Get.context == null) return;
      Get.snackbar(
        error.title,
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: error.color.withValues(alpha: 0.95),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration:
            Duration(seconds: error.type == ApiErrorType.network ? 4 : 3),
        icon: Icon(error.icon, color: Colors.white),
      );
    } catch (_) {
      // No UI context available — silently skip the snackbar.
    }
  }
}

// ─── Models ───────────────────────────────────────────────────

enum ApiErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  badRequest,
  conflict,
  gone,
  validation,
  rateLimited,
  serverError,
  serverUnavailable,
  cancelled,
  unknown,
}

class ApiError {
  final int statusCode;
  final String message;
  final ApiErrorType type;

  const ApiError({
    required this.statusCode,
    required this.message,
    required this.type,
  });

  String get title => switch (type) {
        ApiErrorType.network         => 'No Connection',
        ApiErrorType.timeout         => 'Timeout',
        ApiErrorType.unauthorized    => 'Session Expired',
        ApiErrorType.forbidden       => 'Access Denied',
        ApiErrorType.notFound        => 'Not Found',
        ApiErrorType.badRequest      => 'Bad Request',
        ApiErrorType.conflict        => 'Conflict',
        ApiErrorType.gone            => 'Gone',
        ApiErrorType.validation      => 'Validation Error',
        ApiErrorType.rateLimited     => 'Rate Limited',
        ApiErrorType.serverError     => 'Server Error',
        ApiErrorType.serverUnavailable => 'Unavailable',
        ApiErrorType.cancelled       => 'Cancelled',
        ApiErrorType.unknown         => 'Error',
      };

  Color get color => switch (type) {
        ApiErrorType.network         => const Color(0xFF6B7280),
        ApiErrorType.timeout         => const Color(0xFFF59E0B),
        ApiErrorType.unauthorized    => const Color(0xFF3B82F6),
        ApiErrorType.forbidden       => const Color(0xFFEF4444),
        ApiErrorType.notFound        => const Color(0xFF6B7280),
        ApiErrorType.badRequest      => const Color(0xFFF59E0B),
        ApiErrorType.validation      => const Color(0xFFF59E0B),
        ApiErrorType.rateLimited     => const Color(0xFFF59E0B),
        ApiErrorType.serverError     => const Color(0xFFEF4444),
        ApiErrorType.serverUnavailable => const Color(0xFFEF4444),
        _                            => const Color(0xFF6B7280),
      };

  IconData get icon => switch (type) {
        ApiErrorType.network         => Icons.wifi_off_rounded,
        ApiErrorType.timeout         => Icons.timer_off_rounded,
        ApiErrorType.unauthorized    => Icons.lock_rounded,
        ApiErrorType.forbidden       => Icons.block_rounded,
        ApiErrorType.notFound        => Icons.search_off_rounded,
        ApiErrorType.serverError     => Icons.cloud_off_rounded,
        ApiErrorType.serverUnavailable => Icons.cloud_off_rounded,
        ApiErrorType.validation      => Icons.error_outline_rounded,
        ApiErrorType.rateLimited     => Icons.speed_rounded,
        _                            => Icons.warning_amber_rounded,
      };
}
