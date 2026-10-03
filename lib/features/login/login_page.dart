import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/app/router.dart';
import 'package:new_app/core/network/mock/mock_backend.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';
import 'package:new_app/core/utils/validators.dart';
import 'package:new_app/core/widgets/app_text_field.dart';
import 'package:new_app/core/widgets/auth_layout.dart';
import 'package:new_app/core/widgets/feedback_widgets.dart';
import 'package:new_app/features/login/login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (context) => LoginCubit(context.read(), context.read()), child: const _LoginView());
}

/// Form objects (controllers, focus nodes, form key) are UI state with the
/// widget's lifetime, so they live here — the cubit holds only app state.
class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<LoginCubit>().submit(email: _email.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthLayout(
        title: 'مرحبًا بك',
        subtitle: 'سجّل دخولك للمتابعة',
        brandIcon: Icons.point_of_sale_rounded,
        brandTitle: 'POS Pro',
        brandSubtitle: 'نقطة البيع الذكية',
        form: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                key: const Key('login-email'),
                controller: _email,
                label: 'البريد الإلكتروني',
                hint: MockBackend.demoEmail,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: AppDimensions.md),
              AppPasswordField(
                key: const Key('login-password'),
                controller: _password,
                focusNode: _passwordFocus,
                label: 'كلمة المرور',
                hint: '••••••••',
                textInputAction: TextInputAction.done,
                validator: Validators.loginPassword,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppDimensions.lg),
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.error != null) ErrorBanner(message: state.error!),
                    LoadingButton(label: 'دخول', loading: state.isLoading, onPressed: _submit),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              // Wrap, not Row: survives narrow screens and large text scales.
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('ليس لديك حساب؟', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500)),
                  TextButton(onPressed: () => context.push(AppRoutes.register), child: const Text('إنشاء حساب')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
