import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';
import 'package:new_app/features/session/session_controller.dart';
import 'package:new_app/features/settings/settings_controller.dart';

/// Placeholder home — replace with your first real feature. Shows how a
/// screen reads app-wide state (session, settings) in GetX.
class HomeView extends GetView<SessionController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.to;
    final user = controller.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'الوضع الليلي',
              onPressed: settings.toggleDarkMode,
              icon: Icon(settings.isDarkMode.value ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            ),
          ),
          IconButton(tooltip: 'تسجيل الخروج', onPressed: controller.logout, icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.home_rounded, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: AppDimensions.lg),
            Text('أهلًا، ${user?.name ?? ''}', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppDimensions.sm),
            Text(
              user?.businessName ?? 'Your app starts here.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}
