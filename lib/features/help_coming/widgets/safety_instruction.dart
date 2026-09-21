import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altoque/core/theme/app_colors.dart';
import 'package:altoque/core/theme/app_text_styles.dart';

/// Widget de instrucción de seguridad
class SafetyInstruction extends StatelessWidget {
  final int number;
  final String text;
  final Duration delay;

  const SafetyInstruction({
    super.key,
    required this.number,
    required this.text,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '$number',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.2, end: 0);
  }
}
