import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altoque/core/theme/app_colors.dart';
import 'package:altoque/core/theme/app_text_styles.dart';
import 'package:altoque/shared/widgets/glass_card.dart';
import 'package:altoque/features/settings/widgets/settings_tile.dart';

/// Pantalla de configuración
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _callDelay = 6;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _callDelay = prefs.getInt('callDelay') ?? 6;
    });
  }

  Future<void> _setCallDelay(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('callDelay', value);
    setState(() {
      _callDelay = value;
    });
  }

  void _showTimerPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccionar retraso de llamada',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [3, 5, 6, 7].map((seconds) {
                final isSelected = _callDelay == seconds;
                return InkWell(
                  onTap: () {
                    _setCallDelay(seconds);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${seconds}s',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Configuración',
                      style: AppTextStyles.headlineSmall,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 24),
              // Settings list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Profile section
                    GlassCard(
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Usuario',
                                  style: AppTextStyles.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lima, Perú',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 20),
                    // General settings
                    Text(
                      'GENERAL',
                      style: AppTextStyles.labelSmall.copyWith(
                        letterSpacing: 2,
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
                    const SizedBox(height: 12),
                    SettingsTile(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF4CAF50),
                      title: 'Ubicación',
                      subtitle: 'Detectar distrito automáticamente',
                      delay: const Duration(milliseconds: 250),
                    ),
                    SettingsTile(
                      icon: Icons.contacts_rounded,
                      iconColor: const Color(0xFF2196F3),
                      title: 'Contactos de Emergencia',
                      subtitle: 'Agrega contactos personalizados',
                      delay: const Duration(milliseconds: 300),
                    ),
                    SettingsTile(
                      icon: Icons.timer_rounded,
                      iconColor: const Color(0xFFFF5722),
                      title: 'Retraso de llamada',
                      subtitle: 'Segundos antes de marcar',
                      onTap: () => _showTimerPicker(context),
                      delay: const Duration(milliseconds: 320),
                    ),
                    SettingsTile(
                      icon: Icons.history_rounded,
                      iconColor: const Color(0xFFFF9800),
                      title: 'Historial',
                      subtitle: 'Llamadas recientes',
                      delay: const Duration(milliseconds: 350),
                    ),
                    SettingsTile(
                      icon: Icons.notifications_rounded,
                      iconColor: const Color(0xFF9C27B0),
                      title: 'Notificaciones',
                      subtitle: 'Alertas de seguridad',
                      hasSwitch: true,
                      delay: const Duration(milliseconds: 400),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ACERCA DE',
                      style: AppTextStyles.labelSmall.copyWith(
                        letterSpacing: 2,
                      ),
                    ).animate(delay: 450.ms).fadeIn(duration: 300.ms),
                    const SizedBox(height: 12),
                    SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppColors.textMuted,
                      title: 'Versión',
                      subtitle: '1.0.0',
                      delay: const Duration(milliseconds: 500),
                    ),
                    SettingsTile(
                      icon: Icons.description_rounded,
                      iconColor: AppColors.textMuted,
                      title: 'Términos y Condiciones',
                      subtitle: 'Leer más',
                      delay: const Duration(milliseconds: 550),
                    ),
                    SettingsTile(
                      icon: Icons.privacy_tip_rounded,
                      iconColor: AppColors.textMuted,
                      title: 'Política de Privacidad',
                      subtitle: 'Leer más',
                      delay: const Duration(milliseconds: 600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
