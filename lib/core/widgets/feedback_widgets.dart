import 'package:flutter/material.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';

/// Inline error shown above a form's submit button.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(message, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// Primary button that shows a spinner and disables itself while [loading].
class LoadingButton extends StatelessWidget {
  const LoadingButton({required this.label, required this.loading, required this.onPressed, super.key});

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5),
            )
          : Text(label),
    );
  }
}

/// Password strength bar driven by `Validators.passwordStrength` (0–4).
class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({required this.strength, super.key});

  final int strength;

  @override
  Widget build(BuildContext context) {
    if (strength == 0) return const SizedBox.shrink();
    final (label, color) = switch (strength) {
      1 => ('ضعيفة', AppColors.error),
      2 => ('مقبولة', AppColors.warning),
      3 => ('جيدة', AppColors.info),
      _ => ('قوية', AppColors.success),
    };
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: strength / 4,
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
      ],
    );
  }
}
