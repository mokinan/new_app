import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final _provider = AuthProvider();

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _provider.login(email: email, password: password);
    return AuthResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessName,
  }) async {
    final res = await _provider.register(
      name:         name,
      email:        email,
      password:     password,
      phone:        phone,
      businessName: businessName,
    );
    return AuthResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserModel> getProfile() async {
    final res = await _provider.me();
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logout() => _provider.logout();
}
