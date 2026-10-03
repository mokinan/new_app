import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';
import 'package:new_app/core/widgets/onboarding_widgets.dart';
import 'package:new_app/core/widgets/responsive_builder.dart';
import 'package:new_app/features/welcome/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

        final pages = PageView.builder(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          itemCount: controller.slides.length,
          itemBuilder: (_, i) => SlideContent(slide: controller.slides[i]),
        );
        final footer = Obx(
          () => OnboardingFooter(
            count: controller.slides.length,
            current: controller.currentPage.value,
            isLastPage: controller.isLastPage,
            onNext: controller.next,
          ),
        );
        final skip = Obx(
          () => controller.isLastPage
              ? const SizedBox(height: 48)
              : TextButton(
                  onPressed: controller.finish,
                  child: Text('تخطي', style: AppTextStyles.labelLarge.copyWith(color: AppColors.grey500)),
                ),
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
      }),
    );
  }
}
