import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altoque/core/theme/app_colors.dart';
import 'package:altoque/core/theme/app_text_styles.dart';
import 'package:altoque/core/router/app_router.dart';
import 'package:altoque/shared/widgets/gradient_button.dart';
import 'package:altoque/features/onboarding/widgets/onboarding_page.dart';
import 'package:altoque/features/onboarding/widgets/page_indicator.dart';

/// Pantalla de onboarding con 3 slides de bienvenida
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      icon: Icons.emergency_rounded,
      title: 'Emergencias al\nalcance de tu mano',
      description:
          'Con ALTOQUE puedes contactar a los servicios de emergencia de Perú con un solo toque. Bomberos, Policía, Serenazgo y Ambulancia.',
      iconColor: Color(0xFFE53935),
    ),
    OnboardingPageData(
      icon: Icons.touch_app_rounded,
      title: 'Un toque,\nayuda inmediata',
      description:
          'Sin necesidad de recordar números. Solo selecciona el servicio que necesitas y presiona LLAMAR. La ayuda llegará lo más rápido posible.',
      iconColor: Color(0xFF2196F3),
    ),
    OnboardingPageData(
      icon: Icons.security_rounded,
      title: 'Tu seguridad\nes lo primero',
      description:
          'ALTOQUE detecta tu ubicación para enviar ayuda más rápido. Recibe instrucciones de seguridad mientras esperas a los servicios de emergencia.',
      iconColor: Color(0xFF4CAF50),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (!mounted) return;
    context.go(AppRoutes.permissions);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Saltar',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return OnboardingPage(data: _pages[index]);
                  },
                ),
              ),
              // Indicators and button
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    PageIndicator(
                      currentPage: _currentPage,
                      pageCount: _pages.length,
                    ),
                    const SizedBox(height: 40),
                    GradientButton(
                      text: _currentPage < _pages.length - 1
                          ? 'SIGUIENTE'
                          : 'COMENZAR',
                      icon: _currentPage < _pages.length - 1
                          ? Icons.arrow_forward_rounded
                          : Icons.rocket_launch_rounded,
                      onPressed: _nextPage,
                    ).animate().fadeIn(duration: 500.ms),
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
