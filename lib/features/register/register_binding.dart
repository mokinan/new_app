import 'package:get/get.dart';
import 'package:new_app/features/register/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => RegisterController(Get.find(), Get.find()));
}
