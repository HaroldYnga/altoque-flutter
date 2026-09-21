import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:altoque/core/theme/app_colors.dart';
import 'package:altoque/core/theme/app_text_styles.dart';
import 'package:altoque/core/router/app_router.dart';
import 'package:altoque/shared/widgets/altoque_logo.dart';
import 'package:altoque/shared/widgets/glass_card.dart';

/// Pantalla para solicitar permisos de ubicación
class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, activa los servicios de ubicación.')),
        );
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
    } 

    // When we reach here, permissions are granted or we continue anyway
    if (context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                padding: const EdgeInsets.all(32),
                borderRadius: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AltoqueLogo(size: 80, showText: false)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                        ),
                    const SizedBox(height: 24),
                    Text(
                      'Altoque',
                      style: AppTextStyles.headlineMedium,
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                    const SizedBox(height: 12),
                    Text(
                      'Permitir que "Altoque" acceda a tu ubicación?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                    const SizedBox(height: 16),
                    Text(
                      'Usa tu ubicación para tu seguridad y enviar ayuda más rápido.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.go(AppRoutes.home),
                            child: const Text('Rechazar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _requestPermission(context),
                            child: const Text('Aceptar'),
                          ),
                        ),
                      ],
                    ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
