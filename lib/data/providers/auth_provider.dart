import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';

class AuthProvider {
  final Dio _dio = DioClient.instance;

  /// POST /auth/login
  /// Body: { email, password }
  /// Returns: AuthResponseModel JSON
  Future<Response<dynamic>> login({
    required String email,
    required String password,
  }) =>
      _dio.post(
        ApiEndpoints.login,
        data: {'email': email.trim(), 'password': password},
      );

  /// POST /auth/register
  /// Body: { name, email, password, phone?, business_name? }
  /// Returns: AuthResponseModel JSON
  Future<Response<dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessName,
  }) =>
      _dio.post(
        ApiEndpoints.register,
        data: {
          'name':          name.trim(),
          'email':         email.trim(),
          'password':      password,
          'phone':         phone?.trim(),
          'business_name': businessName?.trim(),
        },
      );

  /// POST /auth/logout
  Future<Response<dynamic>> logout() =>
      _dio.post(ApiEndpoints.logout);

  /// GET /auth/me  — fetch current user profile
  Future<Response<dynamic>> me() =>
      _dio.get(ApiEndpoints.me);
}
