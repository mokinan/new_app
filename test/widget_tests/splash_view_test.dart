import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/features/splash/bindings/splash_binding.dart';
import 'package:new_app/features/splash/views/splash_view.dart';
import '../helpers/test_helpers.dart';

// SplashView contains a CircularProgressIndicator (infinite animation).
// We use pump(duration) instead of pumpAndSettle to avoid timeout.
const _settle = Duration(milliseconds: 100);

void main() {
  setUp(() {
    setupGetX();
    setupAppConfig();
    SplashBinding().dependencies();
  });

  group('SplashView — rendering', () {
    testWidgets('shows app name text', (tester) async {
      await pumpApp(tester, const SplashView(), pump: _settle);
      expect(find.text('AppName'), findsOneWidget);
    });

    testWidgets('shows tagline text', (tester) async {
      await pumpApp(tester, const SplashView(), pump: _settle);
      expect(find.text('Your tagline here'), findsOneWidget);
    });

    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(testableWidget(const SplashView()));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows bolt icon', (tester) async {
      await pumpApp(tester, const SplashView(), pump: _settle);
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    });

    testWidgets('background scaffold has a color set', (tester) async {
      await pumpApp(tester, const SplashView(), pump: _settle);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });
  });
}
