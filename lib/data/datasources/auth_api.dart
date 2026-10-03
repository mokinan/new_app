import 'package:dio/dio.dart';
import 'package:new_app/core/network/api_endpoints.dart';
import 'package:new_app/core/network/interceptors/error_interceptor.dart';
import 'package:new_app/data/models/auth_response_model.dart';
import 'package:new_app/data/models/user_model.dart';

/// Remote auth endpoints. Throws `ApiException` on failure.
///
/// (Named `*Api` rather than `*Provider` to avoid confusion with the
/// `provider` package used in one of the template's branches.)
class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  /// POST /auth/login → { user, access_token, refresh_token, expires_in }
  Future<AuthResponseModel> login({required String email, required String password}) => _call(() async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'email': email.trim(), 'password': password},
    );
    return AuthResponseModel.fromJson(res.data!);
  });

  /// POST /auth/register → same shape as login.
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessName,
  }) => _call(() async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'phone': phone?.trim(),
        'business_name': businessName?.trim(),
      },
    );
    return AuthResponseModel.fromJson(res.data!);
  });

  /// GET /auth/me
  Future<UserModel> me() => _call(() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
    return UserModel.fromJson(res.data!);
  });

  /// POST /auth/logout
  Future<void> logout() => _call(() => _dio.post<void>(ApiEndpoints.logout));

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw e.apiException;
    }
  }
}
