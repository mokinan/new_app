import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository _repo;
  LoginController(this._repo);

  // ─── Form ──────────────────────────────────────────────────
  final formKey        = GlobalKey<FormState>();
  final emailCtrl      = TextEditingController();
  final passwordCtrl   = TextEditingController();
  final emailFocus     = FocusNode();
  final passwordFocus  = FocusNode();

  // ─── State ─────────────────────────────────────────────────
  final isLoading  = false.obs;
  final errorMsg   = RxnString();

  // ─── Actions ───────────────────────────────────────────────
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;
    errorMsg.value  = null;

    try {
      final auth = await _repo.login(
        email:    emailCtrl.text,
        password: passwordCtrl.text,
      );
      await AuthService.to.saveAuth(auth);
      Get.offAllNamed(AppRoutes.home);
    } on Exception catch (e) {
      errorMsg.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() => Get.toNamed(AppRoutes.register);

  // ─── Validators ────────────────────────────────────────────
  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!GetUtils.isEmail(v.trim())) return 'بريد إلكتروني غير صحيح';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
    if (v.length < 6) return 'كلمة المرور 6 أحرف على الأقل';
    return null;
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
