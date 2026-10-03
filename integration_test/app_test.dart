import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

/// Full journey on a device or simulator, against the built-in mock backend:
/// splash → onboarding → login → home → dark mode → logout.
///
/// Run: `flutter test integration_test -d DEVICE_ID`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first launch to logout', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await app.main();

    await tester.pumpUntil(find.text('تخطي'), timeout: const Duration(seconds: 10));
    await tester.tap(find.text('تخطي'));

    await tester.pumpUntil(find.byKey(const Key('login-email')));
    await tester.enterText(find.byKey(const Key('login-email')), MockBackend.demoEmail);
    await tester.enterText(find.byKey(const Key('login-password')), MockBackend.demoPassword);
    await tester.tap(find.text('دخول'));

    await tester.pumpUntil(find.text('أهلًا، محمد أحمد'));
    await tester.tap(find.byTooltip('الوضع الليلي'));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('الرئيسية'))).brightness, Brightness.dark);

    await tester.tap(find.byTooltip('تسجيل الخروج'));
    await tester.pumpUntil(find.text('سجّل دخولك للمتابعة'));
  });
}

extension on WidgetTester {
  Future<void> pumpUntil(Finder finder, {Duration timeout = const Duration(seconds: 8)}) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump(const Duration(milliseconds: 100));
      if (any(finder)) return;
    }
    throw TestFailure('Timed out waiting for $finder');
  }
}
