import 'package:flutter/material.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';
import 'package:new_app/core/widgets/responsive_builder.dart';

/// Layout shared by the login and register screens: a scrolling column on
/// phones, a branding panel + form split on tablets and desktops.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    required this.title,
    required this.subtitle,
    required this.brandIcon,
    required this.brandTitle,
    required this.brandSubtitle,
    required this.form,
    this.brandColors = const [AppColors.primary, AppColors.primaryDark],
    this.onBack,
    this.formMaxWidth = 440,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData brandIcon;
  final String brandTitle;
  final String brandSubtitle;
  final List<Color> brandColors;
  final Widget form;
  final VoidCallback? onBack;
  final double formMaxWidth;

  @override
  Widget build(BuildContext context) {
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headlineMedium),
        const SizedBox(height: 6),
        Text(subtitle, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500)),
      ],
    );

    return ResponsiveBuilder(
      mobile: (context, _) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onBack != null)
                IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_rounded), padding: EdgeInsets.zero)
              else
                const SizedBox(height: AppDimensions.xl),
              const SizedBox(height: AppDimensions.md),
              header,
              const SizedBox(height: AppDimensions.xl),
              form,
            ],
          ),
        ),
      ),
      tablet: (context, _) => Row(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: brandColors),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(brandIcon, size: 80, color: AppColors.white),
                  const SizedBox(height: AppDimensions.lg),
                  Text(brandTitle, style: AppTextStyles.headlineLarge.copyWith(color: AppColors.white)),
                  const SizedBox(height: AppDimensions.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
                    child: Text(
                      brandSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white.withValues(alpha: .75)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formMaxWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      header,
                      const SizedBox(height: AppDimensions.xl),
                      form,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
