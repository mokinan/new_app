import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/core/network/api_endpoints.dart';
import 'package:new_app/core/network/api_exception.dart';

import '../helpers/core_harness.dart';

DioException _status(int code, [Object? body]) {
  final options = RequestOptions(path: '/x');
  return DioException.badResponse(
    statusCode: code,
    requestOptions: options,
    response: Response<Object?>(requestOptions: options, statusCode: code, data: body),
  );
}

void main() {
  group('ApiException.fromDio', () {
    test('maps HTTP status codes to types', () {
      final cases = {
        400: ApiErrorType.badRequest,
        401: ApiErrorType.unauthorized,
        403: ApiErrorType.forbidden,
        404: ApiErrorType.notFound,
        409: ApiErrorType.conflict,
        422: ApiErrorType.validation,
        429: ApiErrorType.rateLimited,
        500: ApiErrorType.serverError,
        502: ApiErrorType.serverError,
        503: ApiErrorType.serverUnavailable,
        504: ApiErrorType.timeout,
        418: ApiErrorType.unknown,
      };
      cases.forEach((code, type) => expect(ApiException.fromDio(_status(code)).type, type, reason: '$code'));
    });

    test('maps transport failures', () {
      final options = RequestOptions(path: '/x');
      expect(ApiException.fromDio(DioException.connectionError(requestOptions: options, reason: '')).isNetwork, isTrue);
      expect(
        ApiException.fromDio(DioException.receiveTimeout(timeout: Duration.zero, requestOptions: options)).type,
        ApiErrorType.timeout,
      );
      expect(
        ApiException.fromDio(DioException.requestCancelled(requestOptions: options, reason: '')).type,
        ApiErrorType.cancelled,
      );
    });

    test('prefers the server message and keeps field errors', () {
      final e = ApiException.fromDio(
        _status(422, {
          'message': 'Email taken',
          'errors': {
            'email': ['Email taken'],
          },
        }),
      );
      expect(e.message, 'Email taken');
      expect(e.fieldErrors['email'], ['Email taken']);
      expect(e.statusCode, 422);
    });
  });

  group('AuthInterceptor', () {
    late CoreHarness core;

    setUp(() async {
      core = await CoreHarness.create();
      await core.signIn();
    });

    test('attaches the token', () async {
      final res = await core.dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      expect(res.data!['email'], 'demo@app.com');
    });

    test('refreshes once for concurrent 401s and replays every request', () async {
      final before = await core.storage.getRefreshToken();
      core.backend.expireAccessTokens();

      final results = await Future.wait(List.generate(4, (_) => core.dio.get<Map<String, dynamic>>(ApiEndpoints.me)));

      expect(results.map((r) => r.statusCode), everyElement(200));
      expect(await core.storage.getRefreshToken(), isNot(before), reason: 'rotated exactly once');
      expect(core.sessionExpiredCount, 0);
    });

    test('ends the session when the refresh token is rejected', () async {
      await core.secure.write('refresh_token', 'revoked');
      core.backend.expireAccessTokens();

      await expectLater(core.dio.get<Object?>(ApiEndpoints.me), throwsA(isA<DioException>()));
      expect(core.sessionExpiredCount, 1);
      expect(await core.storage.getAccessToken(), isNull);
    });
  });
}
