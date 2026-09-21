import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altoque/core/theme/app_text_styles.dart';
import 'package:altoque/core/constants/emergency_services.dart';
import 'package:altoque/core/router/app_router.dart';
import 'package:altoque/shared/widgets/gradient_button.dart';
import 'package:altoque/features/help_coming/widgets/safety_instruction.dart';

/// Pantalla de confirmación: ayuda en camino
class HelpComingScreen extends StatelessWidget {
  final EmergencyService service;

  const HelpComingScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 1),
              // Título
              Text(
                'AYUDA EN CAMINO',
                style: AppTextStyles.displayMedium.copyWith(
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 8),
              Text(
                service.description,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
              // Ícono de confirmación
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      service.iconColor,
                      service.iconColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: service.iconColor.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 40),
              // Instrucciones de seguridad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    for (int i = 0;
                        i < EmergencyServices.safetyInstructions.length;
                        i++)
                      SafetyInstruction(
                        number: i + 1,
                        text: EmergencyServices.safetyInstructions[i],
                        delay: Duration(milliseconds: 600 + (i * 150)),
                      ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // Botón finalizar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: GradientButton(
                  text: 'FINALIZAR LLAMADA',
                  icon: Icons.call_end_rounded,
                  onPressed: () => context.go(AppRoutes.home),
                ),
              )
                  .animate(delay: 1200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.5, end: 0),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
