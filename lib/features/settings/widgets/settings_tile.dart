import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altoque/core/theme/app_colors.dart';
import 'package:altoque/core/theme/app_text_styles.dart';
import 'package:altoque/shared/widgets/glass_card.dart';

/// Tile reutilizable de configuración
class SettingsTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool hasSwitch;
  final VoidCallback? onTap;
  final Duration delay;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.hasSwitch = false,
    this.onTap,
    this.delay = Duration.zero,
  });

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
  bool _switchValue = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: widget.onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            if (widget.hasSwitch)
              Switch(
                value: _switchValue,
                onChanged: (value) {
                  setState(() => _switchValue = value);
                },
                activeThumbColor: AppColors.primary,
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
          ],
        ),
      ),
    )
        .animate(delay: widget.delay)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
