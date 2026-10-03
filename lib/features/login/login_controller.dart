import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:new_app/app/routes/app_routes.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/features/session/session_controller.dart';

/// In GetX the controller owns the form objects (text controllers, focus
/// nodes) and disposes them in `onClose`.
class LoginController extends GetxController {
  LoginController(this._auth, this._session);

  final AuthRepository _auth;
  final SessionController _session;

  // ─── Form ──────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  // ─── State ─────────────────────────────────────────────────
  final isLoading = false.obs;
  final errorMsg = RxnString();

  Future<void> login() async {
    if (isLoading.value || !(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;
    errorMsg.value = null;
    try {
      final user = await _auth.login(email: emailCtrl.text, password: passwordCtrl.text);
      _session.signedIn(user);
      await Get.offAllNamed<void>(AppRoutes.home);
    } on ApiException catch (e) {
      errorMsg.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() => Get.toNamed<void>(AppRoutes.register);

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
