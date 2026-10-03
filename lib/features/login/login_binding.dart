import 'package:get/get.dart';
import 'package:new_app/features/login/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => LoginController(Get.find(), Get.find()));
}
