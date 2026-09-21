import 'package:flutter/material.dart';
import 'package:altoque/core/theme/app_theme.dart';
import 'package:altoque/core/router/app_router.dart';

/// Aplicación principal de ALTOQUE
class AltoqueApp extends StatelessWidget {
  const AltoqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ALTOQUE - Emergencia Perú',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
