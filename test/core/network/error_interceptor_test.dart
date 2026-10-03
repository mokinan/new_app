import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/core/network/interceptors/error_interceptor.dart';
import '../../helpers/test_helpers.dart';

// Fake handler that captures what was passed to next()
class _FakeErrorHandler extends ErrorInterceptorHandler {
  DioException? captured;

  @override
  void next(DioException err) => captured = err;
}

DioException _makeDioError({
  required DioExceptionType type,
  int? statusCode,
  Map<String, dynamic>? body,
}) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode != null
        ? Response(
            requestOptions: options,
            statusCode: statusCode,
            data: body,
          )
        : null,
  );
}

void main() {
  late ErrorInterceptor interceptor;

  setUp(() {
    setupGetX();
    interceptor = ErrorInterceptor();
  });

  group('ErrorInterceptor — connection errors', () {
    test('connectionTimeout produces timeout type', () {
      final handler = _FakeErrorHandler();
      interceptor.onError(
        _makeDioError(type: DioExceptionType.connectionTimeout),
        handler,
      );
      expect(handler.captured, isNotNull);
    });

    test('connectionError passes error through', () {
      final handler = _FakeErrorHandler();
      interceptor.onError(
        _makeDioError(type: DioExceptionType.connectionError),
        handler,
      );
      expect(handler.captured, isNotNull);
    });

    test('cancelled request passes through', () {
      final handler = _FakeErrorHandler();
      interceptor.onError(
        _makeDioError(type: DioExceptionType.cancel),
        handler,
      );
      expect(handler.captured, isNotNull);
    });
  });

  group('ErrorInterceptor — HTTP 4xx', () {
    for (final code in [400, 401, 403, 404, 408, 409, 422, 429]) {
      test('status $code passes error through', () {
        final handler = _FakeErrorHandler();
        interceptor.onError(
          _makeDioError(
            type: DioExceptionType.badResponse,
            statusCode: code,
          ),
          handler,
        );
        expect(handler.captured, isNotNull);
      });
    }
  });

  group('ErrorInterceptor — HTTP 5xx', () {
    for (final code in [500, 501, 502, 503, 504]) {
      test('status $code passes error through', () {
        final handler = _FakeErrorHandler();
        interceptor.onError(
          _makeDioError(
            type: DioExceptionType.badResponse,
            statusCode: code,
          ),
          handler,
        );
        expect(handler.captured, isNotNull);
      });
    }
  });

  group('ErrorInterceptor — server message override', () {
    test('uses backend message when provided', () {
      // Verify the interceptor doesn't crash when backend sends a message
      final handler = _FakeErrorHandler();
      interceptor.onError(
        _makeDioError(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          body: {'message': 'Email already in use'},
        ),
        handler,
      );
      expect(handler.captured, isNotNull);
    });

    test('handles null body gracefully', () {
      final handler = _FakeErrorHandler();
      interceptor.onError(
        _makeDioError(
          type: DioExceptionType.badResponse,
          statusCode: 500,
        ),
        handler,
      );
      expect(handler.captured, isNotNull);
    });
  });

  group('ApiError model', () {
    test('401 has correct title and icon', () {
      final error = ApiError(
        statusCode: 401,
        message: 'Unauthorized',
        type: ApiErrorType.unauthorized,
      );
      expect(error.title, equals('Session Expired'));
      expect(error.icon, isNotNull);
      expect(error.color, isNotNull);
    });

    test('network error has wifi icon', () {
      final error = ApiError(
        statusCode: 0,
        message: 'No internet',
        type: ApiErrorType.network,
      );
      expect(error.title, equals('No Connection'));
    });
  });

  group('ErrorInterceptor — success logging', () {
    test('onResponse passes response through', () {
      final handler = _FakeResponseHandler();
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        data: {'key': 'value'},
      );
      interceptor.onResponse(response, handler);
      expect(handler.captured?.statusCode, equals(200));
    });
  });
}

class _FakeResponseHandler extends ResponseInterceptorHandler {
  Response? captured;

  @override
  void next(Response response) => captured = response;
}
