import 'package:flutter/material.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';
import 'package:new_app/data/models/onboarding_slide_model.dart';

/// One onboarding page: image (or icon) + title + description.
class SlideContent extends StatelessWidget {
  const SlideContent({required this.slide, super.key});

  final OnboardingSlideModel slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (slide.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              child: Image.network(
                slide.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _SlideIcon(),
              ),
            )
          else
            const _SlideIcon(),
          const SizedBox(height: AppDimensions.xl),
          Text(slide.title, style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.md),
          Text(
            slide.description,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SlideIcon extends StatelessWidget {
  const _SlideIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: const Icon(Icons.point_of_sale_rounded, size: 72, color: AppColors.primary),
    );
  }
}

/// Page dots + primary action, shared by every onboarding layout.
class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    required this.count,
    required this.current,
    required this.isLastPage,
    required this.onNext,
    super.key,
  });

  final int count;
  final int current;
  final bool isLastPage;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.md, AppDimensions.lg, AppDimensions.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: current == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: current == i ? AppColors.primary : AppColors.grey300,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: onNext, child: Text(isLastPage ? 'ابدأ الآن' : 'التالي')),
          ),
        ],
      ),
    );
  }
}

/// Splash branding (logo, name, tagline, spinner).
class SplashBranding extends StatelessWidget {
  const SplashBranding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.bolt_rounded, size: 56, color: AppColors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'AppName',
                style: AppTextStyles.displaySmall.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Your tagline here',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white.withValues(alpha: 0.75)),
              ),
              const Spacer(),
              const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
