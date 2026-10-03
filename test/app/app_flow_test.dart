import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';

import '../helpers/app_harness.dart';

/// The same user journeys are tested in every branch of the template, so the
/// state-management layers can be compared on equal terms.
void main() {
  group('start-up routing', () {
    testWidgets('first launch opens onboarding', (tester) async {
      await AppHarness(tester).start();
      expect(find.text('نقطة البيع الذكية'), findsOneWidget);
      expect(find.text('تخطي'), findsOneWidget);
    });

    testWidgets('onboarded users land on login', (tester) async {
      await AppHarness(tester).start(onboarded: true);
      expect(find.text('سجّل دخولك للمتابعة'), findsOneWidget);
    });

    testWidgets('a saved session goes straight home', (tester) async {
      await AppHarness(tester).start(onboarded: true, signedIn: true);
      expect(find.text('أهلًا، محمد أحمد'), findsOneWidget);
    });
  });

  group('onboarding', () {
    testWidgets('next through all slides, then start → login and remembered', (tester) async {
      final app = AppHarness(tester);
      await app.start();

      await app.tapText('التالي');
      await app.tapText('التالي');
      expect(find.text('تخطي'), findsNothing, reason: 'no skip on the last slide');
      await app.tapText('ابدأ الآن');

      expect(find.text('سجّل دخولك للمتابعة'), findsOneWidget);
      expect(app.prefs.getBool('isOnboarded'), isTrue);
    });

    testWidgets('skip goes to login', (tester) async {
      final app = AppHarness(tester);
      await app.start();
      await app.tapText('تخطي');
      expect(find.text('سجّل دخولك للمتابعة'), findsOneWidget);
    });
  });

  group('login', () {
    testWidgets('validates the form before calling the server', (tester) async {
      final app = AppHarness(tester);
      await app.start(onboarded: true);
      await app.tapText('دخول');
      expect(find.text('البريد الإلكتروني مطلوب'), findsOneWidget);
      expect(find.text('كلمة المرور مطلوبة'), findsOneWidget);
    });

    testWidgets('shows the server error for wrong credentials', (tester) async {
      final app = AppHarness(tester);
      await app.start(onboarded: true);
      await app.enter('login-email', MockBackend.demoEmail);
      await app.enter('login-password', 'wrong-password');
      await app.tapText('دخول');
      expect(find.text('البريد الإلكتروني أو كلمة المرور غير صحيحة.'), findsOneWidget);
    });

    testWidgets('signs in and opens home', (tester) async {
      final app = AppHarness(tester);
      await app.start(onboarded: true);
      await app.enter('login-email', MockBackend.demoEmail);
      await app.enter('login-password', MockBackend.demoPassword);
      await app.tapText('دخول');
      expect(find.text('أهلًا، محمد أحمد'), findsOneWidget);
      expect(find.text('متجر الأمين'), findsOneWidget);
    });
  });

  group('register', () {
    Future<AppHarness> openRegister(WidgetTester tester) async {
      final app = AppHarness(tester);
      await app.start(onboarded: true);
      await app.tapText('إنشاء حساب');
      return app;
    }

    Future<void> fill(AppHarness app, {required String email}) async {
      await app.enter('register-business', 'متجر سارة');
      await app.enter('register-owner', 'سارة');
      await app.enter('register-email', email);
      await app.enter('register-password', 'Password1');
      await app.enter('register-confirm', 'Password1');
      await app.tester.pump();
    }

    testWidgets('shows password strength and mismatch errors', (tester) async {
      final app = await openRegister(tester);
      await app.enter('register-password', 'Abcdefg1!');
      await app.enter('register-confirm', 'different');
      await tester.pump();
      expect(find.text('قوية'), findsOneWidget);
      await app.tapText('إنشاء الحساب');
      expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
    });

    testWidgets('a taken email is reported under the field', (tester) async {
      final app = await openRegister(tester);
      await fill(app, email: MockBackend.demoEmail);
      await app.tapText('إنشاء الحساب');
      expect(find.text('هذا البريد مسجل مسبقًا.'), findsWidgets);
    });

    testWidgets('creates the account and opens home', (tester) async {
      final app = await openRegister(tester);
      await fill(app, email: 'sara@shop.sa');
      await app.tapText('إنشاء الحساب');
      expect(find.text('أهلًا، سارة'), findsOneWidget);
    });
  });

  group('home', () {
    testWidgets('logout returns to login and clears the session', (tester) async {
      final app = AppHarness(tester);
      await app.start(onboarded: true, signedIn: true);
      await tester.tap(find.byTooltip('تسجيل الخروج'));
      await app.settle();
      expect(find.text('سجّل دخولك للمتابعة'), findsOneWidget);
      expect(app.prefs.getString('user_json'), isNull);
    });

    testWidgets('dark mode toggles and persists', (tester) async {
      final app = AppHarness(tester);
      await app.start(onboarded: true, signedIn: true);
      await tester.tap(find.byTooltip('الوضع الليلي'));
      await app.settle();
      expect(Theme.of(tester.element(find.text('الرئيسية'))).brightness, Brightness.dark);
      expect(app.prefs.getBool('isDarkMode'), isTrue);
    });
  });

  group('session', () {
    testWidgets('a rejected refresh token sends the user to login', (tester) async {
      final app = AppHarness(tester);
      await app.start(onboarded: true, signedIn: true);
      app.backend.expireAccessTokens();
      await app.expireRefreshToken();

      await app.callProtectedEndpoint();
      expect(find.text('سجّل دخولك للمتابعة'), findsOneWidget);
    });

    testWidgets('a deep link to home while signed out lands on login', (tester) async {
      final app = AppHarness(tester);
      await app.start(onboarded: true, initialRoute: '/home');
      expect(find.text('سجّل دخولك للمتابعة'), findsOneWidget);
      expect(find.textContaining('أهلًا'), findsNothing);
    });
  });
}
