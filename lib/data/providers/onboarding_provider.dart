import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';

class OnboardingProvider {
  final Dio _dio = DioClient.instance;

  /// GET /onboarding/slides
  /// Returns a list of slide objects:
  /// [{ id, title, description, image_url, order }, ...]
  Future<Response<dynamic>> getSlides() =>
      _dio.get(ApiEndpoints.onboardingSlides);
}
