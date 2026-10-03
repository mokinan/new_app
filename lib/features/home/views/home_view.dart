import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Placeholder home screen — replace with your actual home feature.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home_rounded,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text('Home', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Your app starts here.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}
