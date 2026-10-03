import 'package:dio/dio.dart';

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

/// Every failed API call surfaces as an [ApiException]: repositories and
/// state classes catch this one type instead of raw [DioException]s.
class ApiException implements Exception {
  const ApiException({required this.type, required this.message, this.statusCode = 0, this.fieldErrors = const {}});

  /// Maps transport failures and HTTP status codes to a typed error with a
  /// user-facing (Arabic) message. A `message` from the server wins.
  factory ApiException.fromDio(DioException err) {
    final (type, fallback) = switch (err.type) {
      DioExceptionType.connectionTimeout => (ApiErrorType.timeout, 'انتهت مهلة الاتصال. تحقق من الشبكة.'),
      DioExceptionType.sendTimeout => (ApiErrorType.timeout, 'انتهت مهلة إرسال الطلب. حاول مرة أخرى.'),
      DioExceptionType.receiveTimeout => (ApiErrorType.timeout, 'الخادم تأخر في الرد. حاول مرة أخرى.'),
      DioExceptionType.connectionError => (ApiErrorType.network, 'لا يوجد اتصال بالإنترنت.'),
      DioExceptionType.cancel => (ApiErrorType.cancelled, 'تم إلغاء الطلب.'),
      DioExceptionType.badResponse => _fromStatus(err.response?.statusCode ?? 0),
      _ => (ApiErrorType.unknown, 'حدث خطأ غير متوقع.'),
    };
    final body = err.response?.data;
    final serverMessage = body is Map ? body['message'] as String? : null;
    final errors = body is Map && body['errors'] is Map
        ? (body['errors'] as Map).map((k, v) => MapEntry('$k', (v as List).cast<String>()))
        : const <String, List<String>>{};
    return ApiException(
      type: type,
      message: serverMessage ?? fallback,
      statusCode: err.response?.statusCode ?? 0,
      fieldErrors: errors,
    );
  }

  final ApiErrorType type;
  final String message;
  final int statusCode;

  /// Per-field validation messages from a 422 response.
  final Map<String, List<String>> fieldErrors;

  static (ApiErrorType, String) _fromStatus(int code) => switch (code) {
    400 => (ApiErrorType.badRequest, 'طلب غير صالح. راجع البيانات المدخلة.'),
    401 => (ApiErrorType.unauthorized, 'انتهت الجلسة. سجّل الدخول مرة أخرى.'),
    403 => (ApiErrorType.forbidden, 'ليس لديك صلاحية لهذا الإجراء.'),
    404 => (ApiErrorType.notFound, 'العنصر المطلوب غير موجود.'),
    408 => (ApiErrorType.timeout, 'انتهت مهلة الطلب. حاول مرة أخرى.'),
    409 => (ApiErrorType.conflict, 'حدث تعارض. حاول مرة أخرى.'),
    410 => (ApiErrorType.gone, 'هذا العنصر لم يعد متاحًا.'),
    422 => (ApiErrorType.validation, 'البيانات غير صحيحة. راجعها وحاول مجددًا.'),
    429 => (ApiErrorType.rateLimited, 'طلبات كثيرة. انتظر قليلًا ثم حاول.'),
    503 => (ApiErrorType.serverUnavailable, 'الخدمة غير متاحة مؤقتًا.'),
    504 => (ApiErrorType.timeout, 'انتهت مهلة البوابة. حاول لاحقًا.'),
    >= 500 => (ApiErrorType.serverError, 'خطأ في الخادم. نعمل على حله.'),
    _ => (ApiErrorType.unknown, 'حدث خطأ ($code).'),
  };

  bool get isNetwork => type == ApiErrorType.network || type == ApiErrorType.timeout;

  @override
  String toString() => 'ApiException(${type.name}, $statusCode): $message';
}
