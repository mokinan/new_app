import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/auth_repository.dart';

class RegisterController extends GetxController {
  final AuthRepository _repo;
  RegisterController(this._repo);

  // ─── Form ──────────────────────────────────────────────────
  final formKey             = GlobalKey<FormState>();
  final businessNameCtrl    = TextEditingController();
  final ownerNameCtrl       = TextEditingController();
  final emailCtrl           = TextEditingController();
  final phoneCtrl           = TextEditingController();
  final passwordCtrl        = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  final businessNameFocus    = FocusNode();
  final ownerNameFocus       = FocusNode();
  final emailFocus           = FocusNode();
  final phoneFocus           = FocusNode();
  final passwordFocus        = FocusNode();
  final confirmPasswordFocus = FocusNode();

  // ─── State ─────────────────────────────────────────────────
  final isLoading  = false.obs;
  final errorMsg   = RxnString();

  // ─── Actions ───────────────────────────────────────────────
  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;
    errorMsg.value  = null;

    try {
      final auth = await _repo.register(
        name:         ownerNameCtrl.text,
        email:        emailCtrl.text,
        password:     passwordCtrl.text,
        phone:        phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
        businessName: businessNameCtrl.text.isEmpty ? null : businessNameCtrl.text,
      );
      await AuthService.to.saveAuth(auth);
      Get.offAllNamed(AppRoutes.home);
    } on Exception catch (e) {
      errorMsg.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.back();

  // ─── Validators ────────────────────────────────────────────
  String? validateRequired(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName مطلوب';
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!GetUtils.isEmail(v.trim())) return 'بريد إلكتروني غير صحيح';
    return null;
  }

  String? validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return null; // optional
    if (!GetUtils.isPhoneNumber(v.trim())) return 'رقم هاتف غير صحيح';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
    if (v.length < 8) return 'كلمة المرور 8 أحرف على الأقل';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'يجب أن تحتوي على حرف كبير';
    if (!v.contains(RegExp(r'[0-9]'))) return 'يجب أن تحتوي على رقم';
    return null;
  }

  String? validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (v != passwordCtrl.text) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  @override
  void onClose() {
    businessNameCtrl.dispose();
    ownerNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    businessNameFocus.dispose();
    ownerNameFocus.dispose();
    emailFocus.dispose();
    phoneFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.onClose();
  }
}
