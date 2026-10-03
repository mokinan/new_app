import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/data/models/onboarding_slide_model.dart';
import 'package:new_app/data/repositories/onboarding_repository.dart';
import 'package:new_app/features/welcome/controllers/welcome_controller.dart';
import '../../helpers/test_helpers.dart';

// ─── Mock ─────────────────────────────────────────────────────
class MockOnboardingRepository extends Mock implements OnboardingRepository {}

// Fake slides returned by the mock
const _fakeSlides = [
  OnboardingSlideModel(id: 1, order: 1, title: 'Slide 1',
      description: 'Desc 1', imageUrl: ''),
  OnboardingSlideModel(id: 2, order: 2, title: 'Slide 2',
      description: 'Desc 2', imageUrl: ''),
  OnboardingSlideModel(id: 3, order: 3, title: 'Slide 3',
      description: 'Desc 3', imageUrl: ''),
];

void main() {
  late WelcomeController controller;
  late MockOnboardingRepository mockRepo;

  setUp(() async {
    setupGetX();
    setupAppConfig();

    mockRepo = MockOnboardingRepository();
    // Default: return 3 slides
    when(() => mockRepo.getSlides())
        .thenAnswer((_) async => List.of(_fakeSlides));

    controller = Get.put(WelcomeController(mockRepo));
    // onInit calls _loadSlides() which is async — pump the microtask queue
    // and give the Future time to complete.
    await Future.delayed(const Duration(milliseconds: 50));
  });

  tearDown(() => controller.onClose());

  group('WelcomeController — slides loading', () {
    test('fetches slides from repository', () {
      verify(() => mockRepo.getSlides()).called(1);
    });

    test('slides list has 3 items after load', () {
      expect(controller.slides.length, equals(3));
    });

    test('isLoading is false after load', () {
      expect(controller.isLoading.value, isFalse);
    });

    test('hasError is false on success', () {
      expect(controller.hasError.value, isFalse);
    });

    test('falls back to hardcoded slides when API throws', () async {
      final failRepo = MockOnboardingRepository();
      when(() => failRepo.getSlides()).thenThrow(Exception('network error'));

      final ctrl = WelcomeController(failRepo);
      Get.put(ctrl, tag: 'fallback');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(ctrl.slides.isNotEmpty, isTrue);
      expect(ctrl.isLoading.value, isFalse);
      ctrl.onClose();
    });
  });

  group('WelcomeController — pagination', () {
    test('starts on page 0', () {
      expect(controller.currentPage.value, equals(0));
    });

    test('isLastPage is false on page 0', () {
      controller.currentPage.value = 0;
      expect(controller.isLastPage, isFalse);
    });

    test('isLastPage is true on the last slide', () {
      controller.currentPage.value = controller.slides.length - 1;
      expect(controller.isLastPage, isTrue);
    });

    test('onPageChanged updates currentPage', () {
      controller.onPageChanged(2);
      expect(controller.currentPage.value, equals(2));
    });
  });

  group('WelcomeController — slide content', () {
    test('each slide has non-empty title and description', () {
      for (final slide in controller.slides) {
        expect(slide.title, isNotEmpty);
        expect(slide.description, isNotEmpty);
      }
    });
  });

  group('WelcomeController — onboarding completion', () {
    test('setOnboarded(true) persists the flag', () async {
      expect(AppConfig.to.isOnboarded, isFalse);
      await AppConfig.to.setOnboarded(true);
      expect(AppConfig.to.isOnboarded, isTrue);
    });
  });
}
