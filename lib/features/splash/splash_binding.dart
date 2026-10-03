import 'package:get/get.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/features/splash/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // `put`, not `lazyPut`: the view never reads the controller, so a lazy
    // instance would never be created and onReady() would never navigate.
    Get.put(
      SplashController(
        auth: Get.find(),
        preferences: Get.find(),
        session: Get.find(),
        delay: Get.find<AppConfig>().splashDelay,
      ),
    );
  }
}
