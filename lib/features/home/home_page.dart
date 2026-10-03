import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';
import 'package:new_app/features/session/session_bloc.dart';
import 'package:new_app/features/settings/settings_bloc.dart';

/// Placeholder home — replace with your first real feature. Shows how a
/// screen reads app-wide state (session, settings) with `context.select`.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((SessionBloc c) => c.state.user);
    final isDarkMode = context.select((SettingsBloc c) => c.state.isDarkMode);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        actions: [
          IconButton(
            tooltip: 'الوضع الليلي',
            onPressed: () => context.read<SettingsBloc>().add(const SettingsDarkModeToggled()),
            icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            onPressed: () => context.read<SessionBloc>().add(const SessionLogoutRequested()),
            icon: const Icon(Icons.logout_rounded),
          ),
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
