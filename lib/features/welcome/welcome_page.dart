import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/app/router.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';
import 'package:new_app/core/widgets/onboarding_widgets.dart';
import 'package:new_app/core/widgets/responsive_builder.dart';
import 'package:new_app/features/welcome/welcome_cubit.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => WelcomeCubit(context.read(), context.read())..load(),
    child: const _WelcomeView(),
  );
}

class _WelcomeView extends StatefulWidget {
  const _WelcomeView();

  @override
  State<_WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<_WelcomeView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next(WelcomeState state) async {
    if (state.isLastPage) return context.read<WelcomeCubit>().finish();
    await _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WelcomeCubit>();
    return Scaffold(
      body: BlocConsumer<WelcomeCubit, WelcomeState>(
        listenWhen: (previous, current) => !previous.finished && current.finished,
        listener: (context, _) => context.go(AppRoutes.login),
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());

          final pages = PageView.builder(
            controller: _pageController,
            onPageChanged: cubit.pageChanged,
            itemCount: state.slides.length,
            itemBuilder: (_, i) => SlideContent(slide: state.slides[i]),
          );
          final footer = OnboardingFooter(
            count: state.slides.length,
            current: state.page,
            isLastPage: state.isLastPage,
            onNext: () => _next(state),
          );
          final skip = state.isLastPage
              ? const SizedBox(height: 48)
              : TextButton(
                  onPressed: cubit.finish,
                  child: Text('تخطي', style: AppTextStyles.labelLarge.copyWith(color: AppColors.grey500)),
                );

          return ResponsiveBuilder(
            mobile: (_, _) => SafeArea(
              child: Column(
                children: [
                  Align(alignment: AlignmentDirectional.centerEnd, child: skip),
                  Expanded(child: pages),
                  footer,
                ],
              ),
            ),
            tablet: (_, _) => Row(
              children: [
                const Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                    ),
                    child: Center(child: Icon(Icons.point_of_sale_rounded, size: 120, color: AppColors.white)),
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.xl),
                      child: Column(
                        children: [
                          Align(alignment: AlignmentDirectional.centerEnd, child: skip),
                          Expanded(child: pages),
                          footer,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
