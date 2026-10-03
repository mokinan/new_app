import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/responsive_builder.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        mobile:  (ctx, _) => _MobileRegister(c: controller),
        tablet:  (ctx, _) => _SplitLayout(c: controller),
        desktop: (ctx, _) => _SplitLayout(c: controller, maxWidth: 480),
      ),
    );
  }
}

// ─── Mobile ───────────────────────────────────────────────────
class _MobileRegister extends StatelessWidget {
  const _MobileRegister({required this.c});
  final RegisterController c;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back arrow
            IconButton(
              onPressed: c.goToLogin,
              icon: const Icon(Icons.arrow_back_ios_rounded),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppDimensions.md),
            _Header(),
            const SizedBox(height: AppDimensions.xl),
            _RegisterForm(c: c),
          ],
        ),
      ),
    );
  }
}

// ─── Tablet / Desktop split ───────────────────────────────────
class _SplitLayout extends StatelessWidget {
  const _SplitLayout({required this.c, this.maxWidth});
  final RegisterController c;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.secondary, AppColors.secondaryDark],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store_rounded,
                    size: 80, color: AppColors.white),
                const SizedBox(height: AppDimensions.lg),
                Text('انضم إلينا',
                    style: AppTextStyles.headlineLarge
                        .copyWith(color: AppColors.white)),
                const SizedBox(height: AppDimensions.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.xxl),
                  child: Text(
                    'أنشئ حسابك الآن وابدأ في إدارة مبيعاتك',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white.withValues(alpha: .75)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth ?? 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(),
                    const SizedBox(height: AppDimensions.xl),
                    _RegisterForm(c: c),
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

// ─── Shared ───────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إنشاء حساب', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 6),
        Text('أدخل بيانات نشاطك التجاري',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500)),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({required this.c});
  final RegisterController c;

  void _next(BuildContext ctx, FocusNode node) =>
      FocusScope.of(ctx).requestFocus(node);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Business name ─────────────────────────────────────
          AppTextField(
            controller:      c.businessNameCtrl,
            focusNode:       c.businessNameFocus,
            label:           'اسم النشاط التجاري',
            hint:            'مثال: متجر الأمين',
            prefixIcon:      Icons.store_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) => c.validateRequired(v, 'اسم النشاط التجاري'),
            onFieldSubmitted: (_) => _next(context, c.ownerNameFocus),
          ),
          const SizedBox(height: AppDimensions.md),

          // ── Owner name ────────────────────────────────────────
          AppTextField(
            controller:      c.ownerNameCtrl,
            focusNode:       c.ownerNameFocus,
            label:           'اسم المالك',
            hint:            'الاسم الكامل',
            prefixIcon:      Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) => c.validateRequired(v, 'اسم المالك'),
            onFieldSubmitted: (_) => _next(context, c.emailFocus),
          ),
          const SizedBox(height: AppDimensions.md),

          // ── Email ─────────────────────────────────────────────
          AppTextField(
            controller:      c.emailCtrl,
            focusNode:       c.emailFocus,
            label:           'البريد الإلكتروني',
            hint:            'example@email.com',
            prefixIcon:      Icons.email_outlined,
            keyboardType:    TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints:   const [AutofillHints.email],
            validator:       c.validateEmail,
            onFieldSubmitted: (_) => _next(context, c.phoneFocus),
          ),
          const SizedBox(height: AppDimensions.md),

          // ── Phone ─────────────────────────────────────────────
          AppTextField(
            controller:      c.phoneCtrl,
            focusNode:       c.phoneFocus,
            label:           'رقم الهاتف (اختياري)',
            hint:            '+966 5x xxx xxxx',
            prefixIcon:      Icons.phone_outlined,
            keyboardType:    TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))],
            validator:       c.validatePhone,
            onFieldSubmitted: (_) => _next(context, c.passwordFocus),
          ),
          const SizedBox(height: AppDimensions.md),

          // ── Password ──────────────────────────────────────────
          AppPasswordField(
            controller:      c.passwordCtrl,
            focusNode:       c.passwordFocus,
            label:           'كلمة المرور',
            hint:            '8 أحرف على الأقل',
            textInputAction: TextInputAction.next,
            validator:       c.validatePassword,
            onFieldSubmitted: (_) => _next(context, c.confirmPasswordFocus),
          ),
          const SizedBox(height: AppDimensions.sm),
          _PasswordStrength(controller: c.passwordCtrl),
          const SizedBox(height: AppDimensions.md),

          // ── Confirm password ──────────────────────────────────
          AppPasswordField(
            controller:      c.confirmPasswordCtrl,
            focusNode:       c.confirmPasswordFocus,
            label:           'تأكيد كلمة المرور',
            hint:            '••••••••',
            textInputAction: TextInputAction.done,
            validator:       c.validateConfirmPassword,
            onFieldSubmitted: (_) => c.register(),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ── Error ─────────────────────────────────────────────
          Obx(() => c.errorMsg.value != null
              ? _ErrorBanner(message: c.errorMsg.value!)
              : const SizedBox.shrink()),

          // ── Submit ────────────────────────────────────────────
          Obx(() => ElevatedButton(
                onPressed: c.isLoading.value ? null : c.register,
                child: c.isLoading.value
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            color: AppColors.white, strokeWidth: 2.5))
                    : const Text('إنشاء الحساب'),
              )),
          const SizedBox(height: AppDimensions.lg),

          // ── Back to login ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('لديك حساب بالفعل؟',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.grey500)),
              TextButton(
                onPressed: c.goToLogin,
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Password strength indicator ─────────────────────────────
class _PasswordStrength extends StatefulWidget {
  const _PasswordStrength({required this.controller});
  final TextEditingController controller;

  @override
  State<_PasswordStrength> createState() => _PasswordStrengthState();
}

class _PasswordStrengthState extends State<_PasswordStrength> {
  double _strength = 0;
  String _label    = '';
  Color  _color    = AppColors.grey300;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_evaluate);
  }

  void _evaluate() {
    final p = widget.controller.text;
    int score = 0;
    if (p.length >= 8)                       score++;
    if (p.contains(RegExp(r'[A-Z]')))        score++;
    if (p.contains(RegExp(r'[0-9]')))        score++;
    if (p.contains(RegExp(r'[!@#\$%^&*]'))) score++;

    // Pattern assignment only works with locals — assign to fields explicitly
    final (label, color) = switch (score) {
      0 => ('',       AppColors.grey300),
      1 => ('ضعيفة',  AppColors.error),
      2 => ('مقبولة', AppColors.warning),
      3 => ('جيدة',   AppColors.info),
      _ => ('قوية',   AppColors.success),
    };

    setState(() {
      _strength = score / 4;
      _label    = label;
      _color    = color;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_evaluate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_strength == 0) return const SizedBox.shrink();
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: _strength,
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation(_color),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Text(_label,
            style: AppTextStyles.labelSmall.copyWith(color: _color)),
      ],
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
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
