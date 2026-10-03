import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:new_app/app/app.dart';
import 'package:new_app/core/config/app_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
  });

  group('App flow — first launch (not onboarded)', () {
    testWidgets('splash → welcome → get started', (tester) async {
      Get.put(
        AppConfig(environment: AppEnvironment.development),
        permanent: true,
      );
      await AppConfig.to.setOnboarded(false);

      await tester.pumpWidget(const App());
      await tester.pump();

      // ── Splash is visible ──────────────────────────────────
      expect(find.text('AppName'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // ── Wait for splash timer (2 s) ────────────────────────
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // ── Welcome screen is shown ────────────────────────────
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);

      // ── Navigate through all 3 pages ──────────────────────
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Continue'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // ── Last page shows Get Started, no Skip ──────────────
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
    });
  });

  group('App flow — returning user (already onboarded)', () {
    testWidgets('splash → home directly', (tester) async {
      Get.put(
        AppConfig(environment: AppEnvironment.development),
        permanent: true,
      );
      await AppConfig.to.setOnboarded(true);

      await tester.pumpWidget(const App());
      await tester.pump();

      // ── Splash is visible ──────────────────────────────────
      expect(find.text('AppName'), findsOneWidget);

      // ── Wait for splash timer ─────────────────────────────
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // ── Home placeholder is shown ─────────────────────────
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });
  });
}
