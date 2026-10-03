import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/app/notifier_listener.dart';
import 'package:new_app/app/router.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';
import 'package:new_app/core/widgets/onboarding_widgets.dart';
import 'package:new_app/core/widgets/responsive_builder.dart';
import 'package:new_app/features/welcome/welcome_notifier.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => WelcomeNotifier(context.read(), context.read())..load(),
    child: NotifierListener<WelcomeNotifier>(
      listener: (context, welcome) {
        if (welcome.finished) context.go(AppRoutes.login);
      },
      child: const _WelcomeView(),
    ),
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

  Future<void> _next(WelcomeNotifier welcome) async {
    if (welcome.isLastPage) return welcome.finish();
    await _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final welcome = context.watch<WelcomeNotifier>();
    if (welcome.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final pages = PageView.builder(
      controller: _pageController,
      onPageChanged: welcome.pageChanged,
      itemCount: welcome.slides.length,
      itemBuilder: (_, i) => SlideContent(slide: welcome.slides[i]),
    );
    final footer = OnboardingFooter(
      count: welcome.slides.length,
      current: welcome.page,
      isLastPage: welcome.isLastPage,
      onNext: () => _next(welcome),
    );
    final skip = welcome.isLastPage
        ? const SizedBox(height: 48)
        : TextButton(
            onPressed: welcome.finish,
            child: Text('تخطي', style: AppTextStyles.labelLarge.copyWith(color: AppColors.grey500)),
          );

    return Scaffold(
      body: ResponsiveBuilder(
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
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
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
      ),
    );
  }
}
