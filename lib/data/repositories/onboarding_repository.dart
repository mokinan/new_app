import '../models/onboarding_slide_model.dart';
import '../providers/onboarding_provider.dart';

class OnboardingRepository {
  final _provider = OnboardingProvider();

  /// Fetches onboarding slides sorted by [order].
  /// Throws on network error — let the controller handle it.
  Future<List<OnboardingSlideModel>> getSlides() async {
    final response = await _provider.getSlides();

    final list = response.data as List<dynamic>;
    final slides = list
        .map((e) => OnboardingSlideModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return slides;
  }
}
