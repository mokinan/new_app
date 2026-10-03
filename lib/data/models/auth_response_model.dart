import 'user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn; // seconds
  final DateTime expiresAt;

  AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.expiresAt,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expires_in'] as int? ?? 3600;
    return AuthResponseModel(
      user:         UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken:  json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn:    expiresIn,
      expiresAt:    DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Considers token expired 60 seconds early to avoid edge-case failures
  bool get isAboutToExpire =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 60)));
}
