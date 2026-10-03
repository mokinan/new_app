import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Use put (not lazyPut): the view never reads `controller`, so a lazy
    // instance would never be created and onReady() would never navigate.
    Get.put<SplashController>(SplashController());
  }
}
