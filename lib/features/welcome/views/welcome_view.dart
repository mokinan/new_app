import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/responsive_builder.dart';
import '../../../data/models/onboarding_slide_model.dart';
import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ResponsiveBuilder(
          mobile:  (ctx, _) => _MobileLayout(controller: controller),
          tablet:  (ctx, _) => _TabletLayout(controller: controller),
          desktop: (ctx, _) => _DesktopLayout(controller: controller),
        );
      }),
    );
  }
}

// ─── Mobile ───────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.controller});
  final WelcomeController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() => controller.isLastPage
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: controller.skip,
                    child: Text('تخطي',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.grey500)),
                  )),
          ),
          Expanded(
            child: Obx(() => PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.slides.length,
                  itemBuilder: (_, i) =>
                      _SlideContent(slide: controller.slides[i]),
                )),
          ),
          _BottomBar(controller: controller),
        ],
      ),
    );
  }
}

// ─── Tablet ───────────────────────────────────────────────────
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.controller});
  final WelcomeController controller;

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
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: const Center(
              child: Icon(Icons.point_of_sale_rounded,
                  size: 120, color: AppColors.white),
            ),
          ),
        ),
        Expanded(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Obx(() => PageView.builder(
                          controller: controller.pageController,
                          onPageChanged: controller.onPageChanged,
                          itemCount: controller.slides.length,
                          itemBuilder: (_, i) =>
                              _SlideContent(slide: controller.slides[i]),
                        )),
                  ),
                  _BottomBar(controller: controller),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Desktop ──────────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.controller});
  final WelcomeController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.maxCardWidth),
        child: Card(
          margin: const EdgeInsets.all(AppDimensions.xl),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 420,
                  child: Obx(() => PageView.builder(
                        controller: controller.pageController,
                        onPageChanged: controller.onPageChanged,
                        itemCount: controller.slides.length,
                        itemBuilder: (_, i) =>
                            _SlideContent(slide: controller.slides[i]),
                      )),
                ),
                _BottomBar(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────
class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.slide});
  final OnboardingSlideModel slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image (network) or placeholder icon
          if (slide.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              child: Image.network(
                slide.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _PosIcon(),
              ),
            )
          else
            _PosIcon(),
          const SizedBox(height: AppDimensions.xl),
          Text(slide.title,
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.md),
          Text(slide.description,
              style:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PosIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.point_of_sale_rounded,
          size: 72, color: AppColors.primary),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});
  final WelcomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.md,
        AppDimensions.lg,
        AppDimensions.lg,
      ),
      child: Column(
        children: [
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: controller.currentPage.value == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: controller.currentPage.value == i
                          ? AppColors.primary
                          : AppColors.grey300,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: AppDimensions.lg),
          Obx(() => ElevatedButton(
                onPressed: controller.nextPage,
                child: Text(controller.isLastPage ? 'ابدأ الآن' : 'التالي'),
              )),
        ],
      ),
    );
  }
}
