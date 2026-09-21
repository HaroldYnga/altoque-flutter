import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:altoque/core/theme/app_colors.dart';
import 'package:altoque/core/theme/app_text_styles.dart';
import 'package:altoque/core/router/app_router.dart';

/// Header de la pantalla principal con logo y botón de settings
class EmergencyHeader extends StatelessWidget {
  const EmergencyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          // Logo pequeño
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ALTOQUE',
                style: AppTextStyles.titleLarge.copyWith(
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Servicios de Emergencia',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          // Settings button
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
