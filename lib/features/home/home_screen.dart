import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:altoque/core/theme/app_colors.dart';
import 'package:altoque/core/theme/app_text_styles.dart';
import 'package:altoque/core/constants/emergency_services.dart';
import 'package:altoque/core/router/app_router.dart';
import 'package:altoque/features/home/widgets/emergency_card.dart';
import 'package:altoque/features/home/widgets/emergency_header.dart';

/// Pantalla principal con lista de servicios de emergencia.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          child: Column(
            children: [
              const EmergencyHeader()
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.3, end: 0),

              // Asistente de voz
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  12,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(
                        AppRoutes.voiceAssistant,
                      );
                    },
                    icon: const Icon(
                      Icons.mic,
                      size: 27,
                    ),
                    label: const Text(
                      'EXPLICA TU EMERGENCIA',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFE0443E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              )
                  .animate(delay: 150.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    20,
                  ),
                  itemCount: EmergencyServices.all.length,
                  itemBuilder: (context, index) {
                    final service =
                    EmergencyServices.all[index];

                    return EmergencyCard(
                      service: service,
                      onCall: () {
                        context.push(
                          AppRoutes.calling,
                          extra: service,
                        );
                      },
                    )
                        .animate(
                      delay: Duration(
                        milliseconds:
                        100 * (index + 1),
                      ),
                    )
                        .fadeIn(duration: 500.ms)
                        .slideX(begin: -0.2, end: 0);
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  bottom: 20,
                ),
                child: Text(
                  'EMERGENCIA PERÚ',
                  style: AppTextStyles.brandText,
                ),
              )
                  .animate(delay: 800.ms)
                  .fadeIn(duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}