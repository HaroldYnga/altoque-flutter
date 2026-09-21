import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import 'package:altoque/core/ai/emergency_ai_result.dart';

class GeminiEmergencyClassifier {
  GeminiEmergencyClassifier() : _model = _createModel();

  final GenerativeModel _model;

  static const Set<String> _allowedServices = {
    'policia',
    'ambulancia',
    'bomberos',
    'serenazgo',
    'no_emergencia',
  };

  static GenerativeModel _createModel() {
    final responseSchema = Schema.object(
      properties: {
        'servicio': Schema.enumString(
          enumValues: [
            'policia',
            'ambulancia',
            'bomberos',
            'serenazgo',
            'no_emergencia',
          ],
        ),
        'prioridad': Schema.enumString(
          enumValues: [
            'baja',
            'media',
            'alta',
            'critica',
          ],
        ),
        'confianza': Schema.number(),
        'explicacion': Schema.string(),
      },
    );

    return FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: GenerationConfig(
        temperature: 0,
        responseMimeType: 'application/json',
        responseSchema: responseSchema,
      ),
      systemInstruction: Content.system(
        '''
Eres el clasificador de emergencias de ALTOQUE, una aplicación peruana.

Analiza la situación expresada por el usuario y selecciona únicamente uno de estos servicios:

policia:
Robos, asaltos, amenazas, personas armadas, agresiones, secuestros, persecuciones o delitos.

ambulancia:
Personas heridas, inconscientes, con dificultad para respirar, convulsiones, sangrado, atropellos, caídas graves o emergencias médicas.

bomberos:
Incendios, humo, explosiones, fugas de gas, rescates o personas atrapadas.

serenazgo:
Ruidos molestos, disturbios menores, desorden público, personas sospechosas o apoyo preventivo municipal.

no_emergencia:
Consultas sobre la aplicación, configuración o situaciones que no describen una emergencia.

Reglas:
- Responde únicamente en formato JSON.
- No inventes teléfonos.
- No inventes ubicaciones.
- No realices diagnósticos médicos.
- La confianza debe estar entre 0 y 1.
- La explicación debe ser breve.
- En caso de peligro inmediato usa prioridad alta o crítica.
''',
      ),
    );
  }

  Future<EmergencyAiResult> classify(String text) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      throw ArgumentError('La frase está vacía.');
    }

    try {
      final response = await _model.generateContent([
        Content.text(
          'Clasifica la siguiente situación:\n"$cleanText"',
        ),
      ]);

      final responseText = response.text;

      if (responseText == null || responseText.trim().isEmpty) {
        throw Exception(
          'Gemini no devolvió una respuesta.',
        );
      }

      final decoded = jsonDecode(responseText);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'La respuesta de Gemini no es un objeto JSON.',
        );
      }

      final result = EmergencyAiResult.fromJson(decoded);

      if (!_allowedServices.contains(result.service)) {
        throw FormatException(
          'Gemini devolvió un servicio no permitido: '
              '${result.service}',
        );
      }

      if (result.confidence < 0 || result.confidence > 1) {
        throw const FormatException(
          'La confianza debe estar entre 0 y 1.',
        );
      }

      return result;
    } catch (error) {
      print('Gemini falló. Se usará el clasificador local: $error');

      return _clasificarLocalmente(cleanText);
    }
  }

  EmergencyAiResult _clasificarLocalmente(String text) {
    final frase = text.toLowerCase();

    if (_contieneAlguna(frase, [
      'robo',
      'robar',
      'robaron',
      'asaltaron',
      'asalto',
      'ladron',
      'ladrón',
      'arma',
      'amenaza',
      'secuestro',
      'agresion',
      'agresión',
    ])) {
      return const EmergencyAiResult(
        service: 'policia',
        priority: 'alta',
        confidence: 0.90,
        explanation:
        'Se detectó una posible situación delictiva que requiere apoyo policial.',
      );
    }

    if (_contieneAlguna(frase, [
      'herido',
      'herida',
      'heridos',
      'heridas',
      'sangre',
      'sangrando',
      'desmayado',
      'desmayada',
      'inconsciente',
      'ambulancia',
      'atropello',
      'atropellaron',
      'atropellado',
      'atropellada',
      'convulsiones',
      'no respira',
      'dificultad para respirar',

      // Accidentes de tránsito
      'accidente',
      'accidente de tránsito',
      'accidente de transito',
      'choque',
      'chocaron',
      'chocó',
      'choco',
      'colisión',
      'colision',
      'se estrelló',
      'se estrello',
      'volcadura',
      'volcó',
      'volco',
      'dos carros',
      'dos autos',
      'dos vehículos',
      'dos vehiculos',
    ])) {
      return const EmergencyAiResult(
        service: 'ambulancia',
        priority: 'critica',
        confidence: 0.90,
        explanation:
        'Se detectó un posible accidente de tránsito que requiere atención médica.',
      );
    }

    if (_contieneAlguna(frase, [
      'incendio',
      'fuego',
      'humo',
      'explosion',
      'explosión',
      'fuga de gas',
      'atrapado',
      'atrapada',
      'atrapados',
      'atrapadas',
      'bomberos',
      'vehículo incendiándose',
      'vehiculo incendiandose',
    ])) {
      return const EmergencyAiResult(
        service: 'bomberos',
        priority: 'critica',
        confidence: 0.90,
        explanation:
        'Se detectó una emergencia que requiere la intervención de los bomberos.',
      );
    }

    if (_contieneAlguna(frase, [
      'ruido',
      'bulla',
      'disturbio',
      'sospechoso',
      'sospechosa',
      'serenazgo',
      'desorden',
      'pelea',
    ])) {
      return const EmergencyAiResult(
        service: 'serenazgo',
        priority: 'media',
        confidence: 0.85,
        explanation:
        'Se detectó una situación de seguridad o desorden que puede atender Serenazgo.',
      );
    }

    return const EmergencyAiResult(
      service: 'no_emergencia',
      priority: 'baja',
      confidence: 0.60,
      explanation:
      'No se encontraron suficientes indicios para identificar una emergencia.',
    );
  }

  bool _contieneAlguna(
      String frase,
      List<String> palabras,
      ) {
    return palabras.any(
          (palabra) => frase.contains(palabra),
    );
  }
}