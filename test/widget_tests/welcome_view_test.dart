import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:new_app/data/models/onboarding_slide_model.dart';
import 'package:new_app/data/repositories/onboarding_repository.dart';
import 'package:new_app/features/welcome/controllers/welcome_controller.dart';
import 'package:new_app/features/welcome/views/welcome_view.dart';
import '../helpers/test_helpers.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

const _fakeSlides = [
  OnboardingSlideModel(id: 1, order: 1, title: 'عنوان ١',
      description: 'وصف ١', imageUrl: ''),
  OnboardingSlideModel(id: 2, order: 2, title: 'عنوان ٢',
      description: 'وصف ٢', imageUrl: ''),
  OnboardingSlideModel(id: 3, order: 3, title: 'عنوان ٣',
      description: 'وصف ٣', imageUrl: ''),
];

// WelcomeView has a CircularProgressIndicator while loading slides —
// use pump(duration) not pumpAndSettle to avoid infinite-animation timeout.
// 600ms: enough for the mock's instant async resolve + reactive rebuild.
const _settle = Duration(milliseconds: 600);

WelcomeController _makeController() {
  final repo = MockOnboardingRepository();
  when(() => repo.getSlides()).thenAnswer((_) async => List.of(_fakeSlides));
  return WelcomeController(repo);
}

void main() {
  setUp(() {
    setupGetX();
    setupAppConfig();
    // Put the controller directly (bypasses the real binding/repository)
    Get.put(_makeController());
  });

  group('WelcomeView — rendering', () {
    testWidgets('shows التالي button on first page', (tester) async {
      await pumpApp(tester, const WelcomeView(), pump: _settle);
      expect(find.text('التالي'), findsOneWidget);
    });

    testWidgets('shows تخطي button on first page', (tester) async {
      await pumpApp(tester, const WelcomeView(), pump: _settle);
      expect(find.text('تخطي'), findsOneWidget);
    });

    testWidgets('shows PageView', (tester) async {
      await pumpApp(tester, const WelcomeView(), pump: _settle);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('shows dot indicators', (tester) async {
      await pumpApp(tester, const WelcomeView(), pump: _settle);
      expect(find.byType(AnimatedContainer), findsWidgets);
    });
  });

  group('WelcomeView — reactive state (controller-driven)', () {
    // PageView.nextPage() scroll physics don't fire onPageChanged reliably in
    // headless tests — drive the controller directly instead.

    testWidgets('ابدأ الآن appears and التالي disappears on last page',
        (tester) async {
      await pumpApp(tester, const WelcomeView(), pump: _settle);

      final ctrl = Get.find<WelcomeController>();
      ctrl.onPageChanged(ctrl.slides.length - 1);
      await tester.pump();

      expect(find.text('ابدأ الآن'), findsOneWidget);
      expect(find.text('التالي'), findsNothing);
    });

    testWidgets('تخطي disappears on last page', (tester) async {
      await pumpApp(tester, const WelcomeView(), pump: _settle);

      final ctrl = Get.find<WelcomeController>();
      ctrl.onPageChanged(ctrl.slides.length - 1);
      await tester.pump();

      expect(find.text('تخطي'), findsNothing);
    });

    testWidgets('تخطي visible on pages before the last', (tester) async {
      await pumpApp(tester, const WelcomeView(), pump: _settle);

      final ctrl = Get.find<WelcomeController>();

      ctrl.onPageChanged(0);
      await tester.pump();
      expect(find.text('تخطي'), findsOneWidget);

      ctrl.onPageChanged(1);
      await tester.pump();
      expect(find.text('تخطي'), findsOneWidget);
    });

    testWidgets('التالي shown on non-last pages', (tester) async {
      await pumpApp(tester, const WelcomeView(), pump: _settle);

      final ctrl = Get.find<WelcomeController>();
      ctrl.onPageChanged(0);
      await tester.pump();
      expect(find.text('التالي'), findsOneWidget);
    });
  });
}
