import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/config/app_config.dart';
import '../../../data/models/onboarding_slide_model.dart';
import '../../../data/repositories/onboarding_repository.dart';

class WelcomeController extends GetxController {
  final OnboardingRepository _repo;

  WelcomeController(this._repo);

  final pageController = PageController();
  final currentPage    = 0.obs;
  final slides         = <OnboardingSlideModel>[].obs;
  final isLoading      = true.obs;
  final hasError       = false.obs;

  bool get isLastPage => currentPage.value == slides.length - 1;

  // Fallback slides shown when API is unavailable
  static const _fallback = [
    OnboardingSlideModel(
      id: 1, order: 1,
      imageUrl: '',
      title: 'نقطة البيع الذكية',
      description: 'أدر مبيعاتك وفواتيرك من مكان واحد بسهولة تامة.',
    ),
    OnboardingSlideModel(
      id: 2, order: 2,
      imageUrl: '',
      title: 'تقارير فورية',
      description: 'تابع مخزونك وأرباحك لحظة بلحظة بتقارير واضحة.',
    ),
    OnboardingSlideModel(
      id: 3, order: 3,
      imageUrl: '',
      title: 'آمن ومتاح دائماً',
      description: 'بياناتك محمية ومتزامنة على جميع أجهزتك.',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSlides();
  }

  Future<void> _loadSlides() async {
    isLoading.value = true;
    hasError.value  = false;
    try {
      final result = await _repo.getSlides();
      slides.value = result.isNotEmpty ? result : _fallback;
    } catch (_) {
      slides.value = _fallback; // silently fall back — UX stays intact
    } finally {
      isLoading.value = false;
    }
  }

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (isLastPage) {
      _finish();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() => _finish();

  Future<void> _finish() async {
    await AppConfig.to.setOnboarded(true);
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
