import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:new_app/core/network/api_exception.dart';

/// Converts every [DioException] into an [ApiException] (available as
/// `error.error`) and logs it. It deliberately shows **no UI**: presenting
/// errors is the job of the state layer, which differs per branch.
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor({Logger? logger, this.log = true})
    : _log = logger ?? Logger(printer: PrettyPrinter(methodCount: 0, dateTimeFormat: DateTimeFormat.none));

  final Logger _log;
  final bool log;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = ApiException.fromDio(err);
    if (log) {
      _log.e('[${apiError.statusCode}] ${err.requestOptions.method} ${err.requestOptions.path} → ${apiError.message}');
    }
    handler.next(err.copyWith(error: apiError, message: apiError.message));
  }
}

/// Unwraps the [ApiException] attached by [ErrorInterceptor].
extension DioExceptionX on DioException {
  ApiException get apiException => error is ApiException ? error! as ApiException : ApiException.fromDio(this);
}
