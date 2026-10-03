import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';
import 'package:new_app/core/utils/validators.dart';
import 'package:new_app/core/widgets/app_text_field.dart';
import 'package:new_app/core/widgets/auth_layout.dart';
import 'package:new_app/core/widgets/feedback_widgets.dart';
import 'package:new_app/features/login/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      body: AuthLayout(
        title: 'مرحبًا بك',
        subtitle: 'سجّل دخولك للمتابعة',
        brandIcon: Icons.point_of_sale_rounded,
        brandTitle: 'POS Pro',
        brandSubtitle: 'نقطة البيع الذكية',
        form: Form(
          key: c.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                key: const Key('login-email'),
                controller: c.emailCtrl,
                focusNode: c.emailFocus,
                label: 'البريد الإلكتروني',
                hint: MockBackend.demoEmail,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
                onFieldSubmitted: (_) => c.passwordFocus.requestFocus(),
              ),
              const SizedBox(height: AppDimensions.md),
              AppPasswordField(
                key: const Key('login-password'),
                controller: c.passwordCtrl,
                focusNode: c.passwordFocus,
                label: 'كلمة المرور',
                hint: '••••••••',
                textInputAction: TextInputAction.done,
                validator: Validators.loginPassword,
                onFieldSubmitted: (_) => c.login(),
              ),
              const SizedBox(height: AppDimensions.lg),
              Obx(() => c.errorMsg.value == null ? const SizedBox.shrink() : ErrorBanner(message: c.errorMsg.value!)),
              Obx(() => LoadingButton(label: 'دخول', loading: c.isLoading.value, onPressed: c.login)),
              const SizedBox(height: AppDimensions.lg),
              // Wrap, not Row: survives narrow screens and large text scales.
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('ليس لديك حساب؟', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500)),
                  TextButton(onPressed: c.goToRegister, child: const Text('إنشاء حساب')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
