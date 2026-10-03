import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:new_app/app/routes/app_routes.dart';
import 'package:new_app/data/models/onboarding_slide_model.dart';
import 'package:new_app/data/repositories/onboarding_repository.dart';
import 'package:new_app/features/settings/settings_controller.dart';

class WelcomeController extends GetxController {
  WelcomeController(this._repo, this._settings);

  final OnboardingRepository _repo;
  final SettingsController _settings;

  final pageController = PageController();
  final currentPage = 0.obs;
  final slides = <OnboardingSlideModel>[].obs;
  final isLoading = true.obs;

  bool get isLastPage => currentPage.value == slides.length - 1;

  @override
  void onInit() {
    super.onInit();
    _loadSlides();
  }

  Future<void> _loadSlides() async {
    isLoading.value = true;
    // The repository never throws: it falls back to built-in slides.
    slides.assignAll(await _repo.getSlides());
    isLoading.value = false;
  }

  void onPageChanged(int index) => currentPage.value = index;

  Future<void> next() async {
    if (isLastPage) return finish();
    await pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  Future<void> finish() async {
    await _settings.completeOnboarding();
    await Get.offAllNamed<void>(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
