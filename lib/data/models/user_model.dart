import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? businessName;
  final String role;
  final String? avatar;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.businessName,
    this.role = 'owner',
    this.avatar,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String?,
    businessName: json['business_name'] as String?,
    role: json['role'] as String? ?? 'owner',
    avatar: json['avatar'] as String?,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'business_name': businessName,
    'role': role,
    'avatar': avatar,
    'created_at': createdAt?.toIso8601String(),
  };

  // ─── Persistence helpers ──────────────────────────────────
  static UserModel? fromJsonString(String json) {
    try {
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  String toJsonString() => jsonEncode(toJson());

  UserModel copyWith({String? name, String? phone, String? businessName, String? avatar}) => UserModel(
    id: id,
    name: name ?? this.name,
    email: email,
    phone: phone ?? this.phone,
    businessName: businessName ?? this.businessName,
    role: role,
    avatar: avatar ?? this.avatar,
    createdAt: createdAt,
  );
}
