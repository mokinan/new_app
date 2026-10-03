import 'package:dio/dio.dart';
import 'package:new_app/core/network/api_endpoints.dart';
import 'package:new_app/core/network/interceptors/error_interceptor.dart';
import 'package:new_app/data/models/onboarding_slide_model.dart';

class OnboardingApi {
  const OnboardingApi(this._dio);

  final Dio _dio;

  /// GET /onboarding/slides → [{ id, title, description, image_url, order }]
  Future<List<OnboardingSlideModel>> getSlides() async {
    try {
      final res = await _dio.get<List<dynamic>>(ApiEndpoints.onboardingSlides);
      return res.data!.cast<Map<String, dynamic>>().map(OnboardingSlideModel.fromJson).toList();
    } on DioException catch (e) {
      throw e.apiException;
    }
  }
}
