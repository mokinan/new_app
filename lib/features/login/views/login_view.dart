import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/responsive_builder.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        mobile:  (ctx, _) => _MobileLogin(c: controller),
        tablet:  (ctx, _) => _SplitLayout(c: controller),
        desktop: (ctx, _) => _SplitLayout(c: controller, maxWidth: 420),
      ),
    );
  }
}

// ─── Mobile ───────────────────────────────────────────────────
class _MobileLogin extends StatelessWidget {
  const _MobileLogin({required this.c});
  final LoginController c;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.xl),
            _Header(),
            const SizedBox(height: AppDimensions.xxl),
            _LoginForm(c: c),
          ],
        ),
      ),
    );
  }
}

// ─── Tablet / Desktop split ───────────────────────────────────
class _SplitLayout extends StatelessWidget {
  const _SplitLayout({required this.c, this.maxWidth});
  final LoginController c;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left: branding panel
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.point_of_sale_rounded,
                    size: 80, color: AppColors.white),
                const SizedBox(height: AppDimensions.lg),
                Text('POS Pro',
                    style: AppTextStyles.headlineLarge
                        .copyWith(color: AppColors.white)),
                const SizedBox(height: AppDimensions.sm),
                Text('نقطة البيع الذكية',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.white.withValues(alpha: .75))),
              ],
            ),
          ),
        ),
        // Right: form
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth ?? 440),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(),
                    const SizedBox(height: AppDimensions.xxl),
                    _LoginForm(c: c),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('مرحباً بك', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 6),
        Text('سجّل دخولك للمتابعة',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500)),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.c});
  final LoginController c;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Email ────────────────────────────────────────────
          AppTextField(
            controller:     c.emailCtrl,
            focusNode:      c.emailFocus,
            label:          'البريد الإلكتروني',
            hint:           'example@email.com',
            prefixIcon:     Icons.email_outlined,
            keyboardType:   TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints:  const [AutofillHints.email],
            validator:      c.validateEmail,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(c.passwordFocus),
          ),
          const SizedBox(height: AppDimensions.md),

          // ── Password ─────────────────────────────────────────
          AppPasswordField(
            controller:     c.passwordCtrl,
            focusNode:      c.passwordFocus,
            label:          'كلمة المرور',
            hint:           '••••••••',
            textInputAction: TextInputAction.done,
            validator:      c.validatePassword,
            onFieldSubmitted: (_) => c.login(),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ── Error banner ──────────────────────────────────────
          Obx(() => c.errorMsg.value != null
              ? _ErrorBanner(message: c.errorMsg.value!)
              : const SizedBox.shrink()),

          // ── Login button ──────────────────────────────────────
          Obx(() => ElevatedButton(
                onPressed: c.isLoading.value ? null : c.login,
                child: c.isLoading.value
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            color: AppColors.white, strokeWidth: 2.5))
                    : const Text('دخول'),
              )),
          const SizedBox(height: AppDimensions.lg),

          // ── Register link ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ليس لديك حساب؟',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.grey500)),
              TextButton(
                onPressed: c.goToRegister,
                child: const Text('إنشاء حساب'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(message,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
