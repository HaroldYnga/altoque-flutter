import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altoque/core/theme/app_colors.dart';
import 'package:altoque/core/theme/app_text_styles.dart';

/// Datos para una página del onboarding
class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;

  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
  });
}

/// Widget de una página individual del onboarding
class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono grande con fondo circular
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.iconColor.withValues(alpha: 0.15),
              border: Border.all(
                color: data.iconColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: data.iconColor.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 72,
              color: data.iconColor,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 48),
          // Título
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge,
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 20),
          // Descripción
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          )
              .animate(delay: 400.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}
