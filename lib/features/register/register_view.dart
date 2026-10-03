import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';
import 'package:new_app/core/utils/validators.dart';
import 'package:new_app/core/widgets/app_text_field.dart';
import 'package:new_app/core/widgets/auth_layout.dart';
import 'package:new_app/core/widgets/feedback_widgets.dart';
import 'package:new_app/features/register/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      body: AuthLayout(
        title: 'إنشاء حساب',
        subtitle: 'أدخل بيانات نشاطك التجاري',
        brandIcon: Icons.store_rounded,
        brandTitle: 'انضم إلينا',
        brandSubtitle: 'أنشئ حسابك الآن وابدأ في إدارة مبيعاتك',
        brandColors: const [AppColors.secondary, AppColors.secondaryDark],
        formMaxWidth: 520,
        onBack: c.goToLogin,
        form: Form(
          key: c.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                key: const Key('register-business'),
                controller: c.businessNameCtrl,
                focusNode: c.businessNameFocus,
                label: 'اسم النشاط التجاري',
                hint: 'مثال: متجر الأمين',
                prefixIcon: Icons.store_rounded,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, 'اسم النشاط التجاري'),
                onFieldSubmitted: (_) => c.ownerNameFocus.requestFocus(),
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                key: const Key('register-owner'),
                controller: c.ownerNameCtrl,
                focusNode: c.ownerNameFocus,
                label: 'اسم المالك',
                hint: 'الاسم الكامل',
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, 'اسم المالك'),
                onFieldSubmitted: (_) => c.emailFocus.requestFocus(),
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                key: const Key('register-email'),
                controller: c.emailCtrl,
                focusNode: c.emailFocus,
                label: 'البريد الإلكتروني',
                hint: 'example@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (v) => Validators.email(v) ?? c.fieldErrors['email'],
                onChanged: (_) => c.fieldErrors.remove('email'),
                onFieldSubmitted: (_) => c.phoneFocus.requestFocus(),
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                key: const Key('register-phone'),
                controller: c.phoneCtrl,
                focusNode: c.phoneFocus,
                label: 'رقم الهاتف (اختياري)',
                hint: '+966 5x xxx xxxx',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))],
                validator: Validators.phone,
                onFieldSubmitted: (_) => c.passwordFocus.requestFocus(),
              ),
              const SizedBox(height: AppDimensions.md),
              AppPasswordField(
                key: const Key('register-password'),
                controller: c.passwordCtrl,
                focusNode: c.passwordFocus,
                label: 'كلمة المرور',
                hint: '8 أحرف على الأقل',
                textInputAction: TextInputAction.next,
                validator: Validators.newPassword,
                onFieldSubmitted: (_) => c.confirmPasswordFocus.requestFocus(),
              ),
              const SizedBox(height: AppDimensions.sm),
              Obx(() => PasswordStrengthBar(strength: c.passwordStrength.value)),
              const SizedBox(height: AppDimensions.md),
              AppPasswordField(
                key: const Key('register-confirm'),
                controller: c.confirmPasswordCtrl,
                focusNode: c.confirmPasswordFocus,
                label: 'تأكيد كلمة المرور',
                hint: '••••••••',
                textInputAction: TextInputAction.done,
                validator: (v) => Validators.confirmPassword(v, c.passwordCtrl.text),
                onFieldSubmitted: (_) => c.register(),
              ),
              const SizedBox(height: AppDimensions.lg),
              Obx(() => c.errorMsg.value == null ? const SizedBox.shrink() : ErrorBanner(message: c.errorMsg.value!)),
              Obx(() => LoadingButton(label: 'إنشاء الحساب', loading: c.isLoading.value, onPressed: c.register)),
              const SizedBox(height: AppDimensions.lg),
              // Wrap, not Row: survives narrow screens and large text scales.
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('لديك حساب بالفعل؟', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500)),
                  TextButton(onPressed: c.goToLogin, child: const Text('تسجيل الدخول')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
