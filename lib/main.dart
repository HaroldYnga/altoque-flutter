import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:altoque/app.dart';
import 'package:altoque/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // App Check para desarrollo.
  // El token debe ser exactamente el mismo registrado en Firebase.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: const AndroidDebugProvider(
      debugToken: '3037FD2E-0B40-4C1F-A404-F7AA4E55B296',
    ),
    providerApple: const AppleDebugProvider(),
  );

  try {
    await FirebaseAppCheck.instance.getToken(true);
    debugPrint('App Check autorizado correctamente');
  } catch (error) {
    debugPrint('Error de App Check: $error');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A2E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AltoqueApp());
}