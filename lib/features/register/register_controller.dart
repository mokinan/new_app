import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:new_app/app/routes/app_routes.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/core/utils/validators.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/features/session/session_controller.dart';

class RegisterController extends GetxController {
  RegisterController(this._auth, this._session);

  final AuthRepository _auth;
  final SessionController _session;

  // ─── Form ──────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final businessNameCtrl = TextEditingController();
  final ownerNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  final businessNameFocus = FocusNode();
  final ownerNameFocus = FocusNode();
  final emailFocus = FocusNode();
  final phoneFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  // ─── State ─────────────────────────────────────────────────
  final isLoading = false.obs;
  final errorMsg = RxnString();
  final passwordStrength = 0.obs;

  /// Server-side field errors (e.g. email already taken), shown under fields.
  final fieldErrors = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    passwordCtrl.addListener(() => passwordStrength.value = Validators.passwordStrength(passwordCtrl.text));
  }

  Future<void> register() async {
    fieldErrors.clear();
    if (isLoading.value || !(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;
    errorMsg.value = null;
    try {
      final user = await _auth.register(
        name: ownerNameCtrl.text,
        email: emailCtrl.text,
        password: passwordCtrl.text,
        phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text,
        businessName: businessNameCtrl.text,
      );
      _session.signedIn(user);
      await Get.offAllNamed<void>(AppRoutes.home);
    } on ApiException catch (e) {
      errorMsg.value = e.message;
      fieldErrors.assignAll({for (final MapEntry(:key, :value) in e.fieldErrors.entries) key: value.first});
      formKey.currentState?.validate();
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.back<void>();

  @override
  void onClose() {
    for (final c in [businessNameCtrl, ownerNameCtrl, emailCtrl, phoneCtrl, passwordCtrl, confirmPasswordCtrl]) {
      c.dispose();
    }
    for (final f in [businessNameFocus, ownerNameFocus, emailFocus, phoneFocus, passwordFocus, confirmPasswordFocus]) {
      f.dispose();
    }
    super.onClose();
  }
}
