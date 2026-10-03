/// Central place for all test JSON fixtures.
/// Add a static getter per model as the app grows.
///
/// Usage:
///   final json = Fixtures.userProfile;
///   final model = UserModel.fromJson(json);
class Fixtures {
  Fixtures._();

  // ─── Auth ─────────────────────────────────────────────────
  static Map<String, dynamic> get loginSuccess => {
        'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test',
        'refresh_token': 'refresh_token_value',
        'expires_in': 3600,
      };

  static Map<String, dynamic> get loginError400 => {
        'message': 'Invalid email or password.',
        'code': 'INVALID_CREDENTIALS',
      };

  static Map<String, dynamic> get loginError401 => {
        'message': 'Unauthorized.',
        'code': 'UNAUTHORIZED',
      };

  // ─── User ─────────────────────────────────────────────────
  static Map<String, dynamic> get userProfile => {
        'id': '1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'avatar': 'https://example.com/avatar.png',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

  static List<Map<String, dynamic>> get userList => [
        userProfile,
        {
          'id': '2',
          'name': 'Jane Smith',
          'email': 'jane@example.com',
          'avatar': null,
          'created_at': '2024-02-01T00:00:00.000Z',
        },
      ];

  // ─── Pagination ───────────────────────────────────────────
  static Map<String, dynamic> paginatedResponse({
    required List<Map<String, dynamic>> data,
    int page = 1,
    int total = 10,
    int perPage = 10,
  }) =>
      {
        'data': data,
        'meta': {
          'current_page': page,
          'total': total,
          'per_page': perPage,
          'last_page': (total / perPage).ceil(),
        },
      };

  // ─── Errors ───────────────────────────────────────────────
  static Map<String, dynamic> serverError([String? message]) => {
        'message': message ?? 'Internal server error.',
        'code': 'SERVER_ERROR',
      };

  static Map<String, dynamic> validationError(
          Map<String, List<String>> errors) =>
      {
        'message': 'Validation failed.',
        'errors': errors,
      };
}
