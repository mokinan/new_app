import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/core/utils/validators.dart';

void main() {
  group('email', () {
    test('accepts valid addresses', () {
      for (final v in ['a@b.co', 'first.last+tag@mail.example.sa', ' demo@app.com ']) {
        expect(Validators.email(v), isNull, reason: v);
      }
    });

    test('rejects empty and malformed input', () {
      expect(Validators.email(''), 'البريد الإلكتروني مطلوب');
      expect(Validators.email(null), 'البريد الإلكتروني مطلوب');
      for (final v in ['plain', 'a@b', '@b.com', 'a b@c.com']) {
        expect(Validators.email(v), 'بريد إلكتروني غير صحيح', reason: v);
      }
    });
  });

  group('phone (optional)', () {
    test('empty is valid', () => expect(Validators.phone(''), isNull));
    test('accepts international and local numbers', () {
      expect(Validators.phone('+966 50 123 4567'), isNull);
      expect(Validators.phone('0501234567'), isNull);
    });
    test('rejects letters and short numbers', () {
      expect(Validators.phone('05x1234567'), 'رقم هاتف غير صحيح');
      expect(Validators.phone('12345'), 'رقم هاتف غير صحيح');
    });
  });

  group('passwords', () {
    test('login only checks presence and length', () {
      expect(Validators.loginPassword(''), 'كلمة المرور مطلوبة');
      expect(Validators.loginPassword('12345'), 'كلمة المرور 6 أحرف على الأقل');
      expect(Validators.loginPassword('abcdef'), isNull);
    });

    test('new password enforces the policy', () {
      expect(Validators.newPassword('Abc123'), 'كلمة المرور 8 أحرف على الأقل');
      expect(Validators.newPassword('abcdefg1'), 'يجب أن تحتوي على حرف كبير');
      expect(Validators.newPassword('Abcdefgh'), 'يجب أن تحتوي على رقم');
      expect(Validators.newPassword('Abcdefg1'), isNull);
    });

    test('confirmation must match', () {
      expect(Validators.confirmPassword('', 'x'), 'تأكيد كلمة المرور مطلوب');
      expect(Validators.confirmPassword('a', 'b'), 'كلمتا المرور غير متطابقتين');
      expect(Validators.confirmPassword('same', 'same'), isNull);
    });

    test('strength counts satisfied rules', () {
      expect(Validators.passwordStrength(''), 0);
      expect(Validators.passwordStrength('abcdefgh'), 1);
      expect(Validators.passwordStrength('Abcdefg1'), 3);
      expect(Validators.passwordStrength('Abcdefg1!'), 4);
    });
  });

  test('required uses the field name', () {
    expect(Validators.required('  ', 'اسم المالك'), 'اسم المالك مطلوب');
    expect(Validators.required('x', 'اسم المالك'), isNull);
  });
}
