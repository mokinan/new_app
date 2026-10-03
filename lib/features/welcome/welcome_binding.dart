import 'package:get/get.dart';
import 'package:new_app/features/welcome/welcome_controller.dart';

class WelcomeBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => WelcomeController(Get.find(), Get.find()));
}
