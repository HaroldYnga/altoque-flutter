import 'package:go_router/go_router.dart';

import 'package:altoque/core/constants/emergency_services.dart';
import 'package:altoque/features/splash/splash_screen.dart';
import 'package:altoque/features/onboarding/onboarding_screen.dart';
import 'package:altoque/features/permissions/permission_screen.dart';
import 'package:altoque/features/home/home_screen.dart';
import 'package:altoque/features/calling/calling_screen.dart';
import 'package:altoque/features/help_coming/help_coming_screen.dart';
import 'package:altoque/features/settings/settings_screen.dart';
import 'package:altoque/features/voice/voice_assistant_screen.dart';

/// Rutas nombradas de la aplicación.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String permissions = '/permissions';
  static const String home = '/home';
  static const String calling = '/calling';
  static const String helpComing = '/help-coming';
  static const String settings = '/settings';
  static const String voiceAssistant = '/voice-assistant';
}

/// Configuración del router.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.permissions,
      builder: (context, state) => const PermissionScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.calling,
      builder: (context, state) {
        final service = state.extra as EmergencyService;

        return CallingScreen(
          service: service,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.helpComing,
      builder: (context, state) {
        final service = state.extra as EmergencyService;

        return HelpComingScreen(
          service: service,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.voiceAssistant,
      builder: (context, state) =>
      const VoiceAssistantScreen(),
    ),
  ],
);