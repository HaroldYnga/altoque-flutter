import 'package:flutter/material.dart';

/// Modelo que representa un servicio de emergencia.
class EmergencyService {
  final String id;
  final String name;
  final String number;
  final IconData icon;
  final String description;
  final Color iconColor;

  const EmergencyService({
    required this.id,
    required this.name,
    required this.number,
    required this.icon,
    required this.description,
    required this.iconColor,
  });
}

/// Servicios disponibles en la aplicación.
class EmergencyServices {
  EmergencyServices._();

  static const List<EmergencyService> all = [

    EmergencyService(
      id: 'bomberos',
      name: 'Bomberos',
      number: '116',
      icon: Icons.local_fire_department,
      description: 'Incendios, rescates y fugas de gas',
      iconColor: Color(0xFFF44336),
    ),
    EmergencyService(
      id: 'policia',
      name: 'Policía Nacional',
      number: '105',
      icon: Icons.local_police,
      description: 'Robos, asaltos, amenazas y delitos',
      iconColor: Color(0xFF2196F3),
    ),
    EmergencyService(
      id: 'ambulancia',
      name: 'Ambulancia',
      number: '106',
      icon: Icons.medical_services,
      description: 'Accidentes y emergencias médicas',
      iconColor: Color(0xFFE53935),
    ),
  ];

  /// Instrucciones mostradas mientras llega la ayuda.
  static const List<String> safetyInstructions = [
    'Mantén la calma.',
    'Indica claramente tu ubicación.',
    'Describe brevemente lo que ocurrió.',
    'Sigue las instrucciones del operador.',
    'No cuelgues hasta que el operador lo indique.',
    'Permanece en un lugar seguro.',
  ];

  /// Busca un servicio usando su identificador.
  static EmergencyService? findById(String id) {
    for (final service in all) {
      if (service.id == id) {
        return service;
      }
    }

    return null;
  }
}