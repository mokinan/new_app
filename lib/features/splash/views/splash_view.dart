import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // ─── Logo placeholder ─────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 56,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AppName',
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your tagline here',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.white.withValues(alpha: 0.75),
                ),
              ),
              const Spacer(),
              // ─── Loading indicator ────────────────────────
              const CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
