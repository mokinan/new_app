import 'package:get/get.dart';
import '../../../data/repositories/onboarding_repository.dart';
import '../controllers/welcome_controller.dart';

class WelcomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WelcomeController>(
      () => WelcomeController(OnboardingRepository()),
    );
  }
}
