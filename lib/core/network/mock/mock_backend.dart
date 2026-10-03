import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:new_app/core/network/api_endpoints.dart';

/// In-process fake of the backend, used when `ENV=mock` (the default).
///
/// It implements the same contract as the real API — tokens, refresh,
/// validation errors — so the template runs out of the box and integration
/// tests need no server. Replace nothing to go live: just build with
/// `--dart-define=ENV=production`.
class MockBackend {
  MockBackend({this.latency = const Duration(milliseconds: 600), this.accessTokenTtl = const Duration(hours: 1)});

  static const demoEmail = 'demo@app.com';
  static const demoPassword = 'Password1';

  final Duration latency;
  final Duration accessTokenTtl;

  late final HttpClientAdapter adapter = _MockAdapter(this);

  final _users = <String, Map<String, dynamic>>{
    demoEmail: {
      'password': demoPassword,
      'user': {
        'id': '1',
        'name': 'محمد أحمد',
        'email': demoEmail,
        'phone': '+966500000000',
        'business_name': 'متجر الأمين',
        'role': 'owner',
        'created_at': '2026-01-01T00:00:00.000Z',
      },
    },
  };
  final _accessTokens = <String, String>{}; // token → email
  final _refreshTokens = <String, String>{}; // token → email
  int _counter = 0;

  /// Invalidates every access token, forcing a refresh on the next call.
  void expireAccessTokens() => _accessTokens.clear();

  (int, Object?) handle(String method, String path, Map<String, dynamic> body, String? bearer) {
    switch ((method, path)) {
      case ('GET', ApiEndpoints.onboardingSlides):
        return (200, _slides);
      case ('POST', ApiEndpoints.login):
        final account = _users[(body['email'] as String? ?? '').trim().toLowerCase()];
        if (account == null || account['password'] != body['password']) {
          return (401, {'message': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.'});
        }
        return (200, _session(account['user'] as Map<String, dynamic>));
      case ('POST', ApiEndpoints.register):
        final email = (body['email'] as String? ?? '').trim().toLowerCase();
        if (_users.containsKey(email)) {
          return (
            422,
            {
              'message': 'هذا البريد مسجل مسبقًا.',
              'errors': {
                'email': ['هذا البريد مسجل مسبقًا.'],
              },
            },
          );
        }
        final user = {
          'id': '${_users.length + 1}',
          'name': body['name'],
          'email': email,
          'phone': body['phone'],
          'business_name': body['business_name'],
          'role': 'owner',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        };
        _users[email] = {'password': body['password'], 'user': user};
        return (201, _session(user));
      case ('POST', ApiEndpoints.refreshToken):
        final email = _refreshTokens.remove(body['refresh_token']);
        if (email == null) return (401, {'message': 'انتهت الجلسة.'});
        return (200, _session(_users[email]!['user'] as Map<String, dynamic>));
      case ('POST', ApiEndpoints.logout):
        _accessTokens.remove(bearer);
        return (204, null);
      case ('GET', ApiEndpoints.me):
        final email = _accessTokens[bearer];
        if (email == null) return (401, {'message': 'انتهت الجلسة.'});
        return (200, _users[email]!['user']);
      default:
        return (404, {'message': 'Not found: $method $path'});
    }
  }

  Map<String, dynamic> _session(Map<String, dynamic> user) {
    final access = 'access-${++_counter}';
    final refresh = 'refresh-$_counter';
    _accessTokens[access] = user['email'] as String;
    _refreshTokens[refresh] = user['email'] as String;
    return {'user': user, 'access_token': access, 'refresh_token': refresh, 'expires_in': accessTokenTtl.inSeconds};
  }

  static const _slides = [
    {
      'id': 1,
      'order': 1,
      'image_url': '',
      'title': 'نقطة البيع الذكية',
      'description': 'أدر مبيعاتك وفواتيرك من مكان واحد بسهولة تامة.',
    },
    {
      'id': 2,
      'order': 2,
      'image_url': '',
      'title': 'تقارير فورية',
      'description': 'تابع مخزونك وأرباحك لحظة بلحظة بتقارير واضحة.',
    },
    {
      'id': 3,
      'order': 3,
      'image_url': '',
      'title': 'آمن ومتاح دائمًا',
      'description': 'بياناتك محمية ومتزامنة على جميع أجهزتك.',
    },
  ];
}

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter(this._backend);

  final MockBackend _backend;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_backend.latency > Duration.zero) await Future<void>.delayed(_backend.latency);
    final data = options.data;
    final body = data is Map<String, dynamic>
        ? data
        : data is String && data.isNotEmpty
        ? jsonDecode(data) as Map<String, dynamic>
        : const <String, dynamic>{};
    final bearer = (options.headers['Authorization'] as String?)?.replaceFirst('Bearer ', '');
    final (status, json) = _backend.handle(options.method, options.path, body, bearer);
    return ResponseBody.fromString(
      json == null ? '' : jsonEncode(json),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
