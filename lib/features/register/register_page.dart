import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';
import 'package:new_app/core/utils/validators.dart';
import 'package:new_app/core/widgets/app_text_field.dart';
import 'package:new_app/core/widgets/auth_layout.dart';
import 'package:new_app/core/widgets/feedback_widgets.dart';
import 'package:new_app/features/register/register_bloc.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (context) => RegisterBloc(context.read(), context.read()), child: const _RegisterView());
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _business = TextEditingController();
  final _owner = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _ownerFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    for (final c in [_business, _owner, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    for (final f in [_ownerFocus, _emailFocus, _phoneFocus, _passwordFocus, _confirmFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<RegisterBloc>().add(
      RegisterSubmitted(
        businessName: _business.text,
        ownerName: _owner.text,
        email: _email.text,
        password: _password.text,
        phone: _phone.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RegisterBloc>();
    return Scaffold(
      body: BlocConsumer<RegisterBloc, RegisterState>(
        // Re-run validation so server field errors appear under their fields.
        listenWhen: (previous, current) => previous.fieldErrors != current.fieldErrors,
        listener: (_, _) => _formKey.currentState?.validate(),
        builder: (context, state) => AuthLayout(
          title: 'إنشاء حساب',
          subtitle: 'أدخل بيانات نشاطك التجاري',
          brandIcon: Icons.store_rounded,
          brandTitle: 'انضم إلينا',
          brandSubtitle: 'أنشئ حسابك الآن وابدأ في إدارة مبيعاتك',
          brandColors: const [AppColors.secondary, AppColors.secondaryDark],
          formMaxWidth: 520,
          onBack: context.pop,
          form: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  key: const Key('register-business'),
                  controller: _business,
                  label: 'اسم النشاط التجاري',
                  hint: 'مثال: متجر الأمين',
                  prefixIcon: Icons.store_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, 'اسم النشاط التجاري'),
                  onFieldSubmitted: (_) => _ownerFocus.requestFocus(),
                ),
                const SizedBox(height: AppDimensions.md),
                AppTextField(
                  key: const Key('register-owner'),
                  controller: _owner,
                  focusNode: _ownerFocus,
                  label: 'اسم المالك',
                  hint: 'الاسم الكامل',
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, 'اسم المالك'),
                  onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                ),
                const SizedBox(height: AppDimensions.md),
                AppTextField(
                  key: const Key('register-email'),
                  controller: _email,
                  focusNode: _emailFocus,
                  label: 'البريد الإلكتروني',
                  hint: 'example@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: (v) => Validators.email(v) ?? state.fieldErrors['email'],
                  onChanged: (_) => bloc.add(const RegisterEmailChanged()),
                  onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                ),
                const SizedBox(height: AppDimensions.md),
                AppTextField(
                  key: const Key('register-phone'),
                  controller: _phone,
                  focusNode: _phoneFocus,
                  label: 'رقم الهاتف (اختياري)',
                  hint: '+966 5x xxx xxxx',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))],
                  validator: Validators.phone,
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: AppDimensions.md),
                AppPasswordField(
                  key: const Key('register-password'),
                  controller: _password,
                  focusNode: _passwordFocus,
                  label: 'كلمة المرور',
                  hint: '8 أحرف على الأقل',
                  textInputAction: TextInputAction.next,
                  validator: Validators.newPassword,
                  onChanged: (v) => bloc.add(RegisterPasswordChanged(v)),
                  onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                ),
                const SizedBox(height: AppDimensions.sm),
                PasswordStrengthBar(strength: state.passwordStrength),
                const SizedBox(height: AppDimensions.md),
                AppPasswordField(
                  key: const Key('register-confirm'),
                  controller: _confirm,
                  focusNode: _confirmFocus,
                  label: 'تأكيد كلمة المرور',
                  hint: '••••••••',
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.confirmPassword(v, _password.text),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppDimensions.lg),
                if (state.error != null) ErrorBanner(message: state.error!),
                LoadingButton(label: 'إنشاء الحساب', loading: state.isLoading, onPressed: _submit),
                const SizedBox(height: AppDimensions.lg),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('لديك حساب بالفعل؟', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500)),
                    TextButton(onPressed: context.pop, child: const Text('تسجيل الدخول')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
