import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altoque/core/theme/app_colors.dart';
import 'package:altoque/core/router/app_router.dart';
import 'package:altoque/shared/widgets/altoque_logo.dart';

/// Pantalla de splash con logo animado
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;
    if (hasSeenOnboarding) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.onboarding);
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AltoqueLogo(size: 140)
                  .animate()
                  .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 60),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  strokeWidth: 2,
                ),
              )
                  .animate(delay: 1200.ms)
                  .fadeIn(duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
