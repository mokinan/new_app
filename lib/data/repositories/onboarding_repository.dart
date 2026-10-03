import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/data/datasources/onboarding_api.dart';
import 'package:new_app/data/models/onboarding_slide_model.dart';

class OnboardingRepository {
  const OnboardingRepository(this._api);

  final OnboardingApi _api;

  /// Slides from the server sorted by `order`, or built-in slides when the
  /// server is unreachable or returns none — onboarding must never block.
  Future<List<OnboardingSlideModel>> getSlides() async {
    try {
      final slides = await _api.getSlides();
      if (slides.isEmpty) return fallbackSlides;
      return [...slides]..sort((a, b) => a.order.compareTo(b.order));
    } on ApiException {
      return fallbackSlides;
    }
  }

  static const fallbackSlides = [
    OnboardingSlideModel(
      id: 1,
      order: 1,
      imageUrl: '',
      title: 'نقطة البيع الذكية',
      description: 'أدر مبيعاتك وفواتيرك من مكان واحد بسهولة تامة.',
    ),
    OnboardingSlideModel(
      id: 2,
      order: 2,
      imageUrl: '',
      title: 'تقارير فورية',
      description: 'تابع مخزونك وأرباحك لحظة بلحظة بتقارير واضحة.',
    ),
    OnboardingSlideModel(
      id: 3,
      order: 3,
      imageUrl: '',
      title: 'آمن ومتاح دائمًا',
      description: 'بياناتك محمية ومتزامنة على جميع أجهزتك.',
    ),
  ];
}
