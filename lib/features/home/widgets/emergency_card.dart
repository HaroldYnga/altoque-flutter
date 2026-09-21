import 'package:flutter/material.dart';
import 'package:altoque/core/theme/app_colors.dart';
import 'package:altoque/core/theme/app_text_styles.dart';
import 'package:altoque/core/constants/emergency_services.dart';
import 'package:altoque/shared/widgets/glass_card.dart';

/// Card de servicio de emergencia con glassmorphism
class EmergencyCard extends StatefulWidget {
  final EmergencyService service;
  final VoidCallback onCall;

  const EmergencyCard({
    super.key,
    required this.service,
    required this.onCall,
  });

  @override
  State<EmergencyCard> createState() => _EmergencyCardState();
}

class _EmergencyCardState extends State<EmergencyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_elevationAnimation.value * 0.2),
            child: child,
          );
        },
        child: GestureDetector(
          onTapDown: (_) => _hoverController.forward(),
          onTapUp: (_) => _hoverController.reverse(),
          onTapCancel: () => _hoverController.reverse(),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // Ícono del servicio
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.service.iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.service.icon,
                    color: widget.service.iconColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                // Información del servicio
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.service.number,
                        style: AppTextStyles.emergencyNumber.copyWith(
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón LLAMAR
                GestureDetector(
                  onTap: widget.onCall,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'LLAMAR',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
