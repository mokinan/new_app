/// Form validators shared by every branch (returning `null` = valid).
///
/// Pure functions — no framework helpers — so they behave identically with
/// GetX, Bloc, Provider or Riverpod and are trivial to unit-test.
abstract final class Validators {
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final _phone = RegExp(r'^\+?[0-9]{9,15}$');

  static String? required(String? value, String fieldName) =>
      (value == null || value.trim().isEmpty) ? '$fieldName مطلوب' : null;

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!_email.hasMatch(value.trim())) return 'بريد إلكتروني غير صحيح';
    return null;
  }

  /// Optional field: empty is valid.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!_phone.hasMatch(value.replaceAll(RegExp(r'\s'), ''))) return 'رقم هاتف غير صحيح';
    return null;
  }

  /// Login: presence and minimum length only — rules may have changed since
  /// the account was created.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 6) return 'كلمة المرور 6 أحرف على الأقل';
    return null;
  }

  /// Registration: the current password policy.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 8) return 'كلمة المرور 8 أحرف على الأقل';
    if (!value.contains(RegExp('[A-Z]'))) return 'يجب أن تحتوي على حرف كبير';
    if (!value.contains(RegExp('[0-9]'))) return 'يجب أن تحتوي على رقم';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (value != password) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  /// Password strength from 0 (empty) to 4.
  static int passwordStrength(String password) => [
    password.length >= 8,
    password.contains(RegExp('[A-Z]')),
    password.contains(RegExp('[0-9]')),
    password.contains(RegExp(r'[!@#$%^&*]')),
  ].where((ok) => ok).length;
}
