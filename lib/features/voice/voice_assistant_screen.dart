import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:altoque/core/ai/emergency_ai_result.dart';
import 'package:altoque/core/ai/gemini_emergency_classifier.dart';
import 'package:altoque/core/constants/emergency_services.dart';
import 'package:altoque/core/router/app_router.dart';
import 'package:altoque/core/theme/app_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:altoque/services/firestore_service.dart';
import 'package:altoque/models/emergency_contact.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() =>
      _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final SpeechToText _speech = SpeechToText();
  final FirestoreService _firestoreService = FirestoreService();
  final GeminiEmergencyClassifier _aiClassifier =
  GeminiEmergencyClassifier();

  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isProcessing = false;

  String _recognizedText = '';
  String _statusText =
      'Presiona el micrófono y explica la emergencia';

  EmergencyAiResult? _aiResult;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;

          if (status == 'listening') {
            setState(() {
              _isListening = true;
              _statusText = 'Escuchando...';
            });
          }

          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _isListening = false;
            _isProcessing = false;
            _statusText = 'No se pudo reconocer la voz';
          });

          _showMessage(
            'Error del micrófono: ${error.errorMsg}',
          );
        },
      );

      if (!mounted) return;

      setState(() {
        _speechAvailable = available;

        _statusText = available
            ? 'Presiona el micrófono y explica la emergencia'
            : 'El reconocimiento de voz no está disponible';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _speechAvailable = false;
        _isProcessing = false;
        _statusText =
        'No se pudo iniciar el reconocimiento de voz';
      });

      _showMessage(
        'Error al iniciar el micrófono: $error',
      );
    }
  }

  Future<void> _startListening() async {
    if (_isProcessing) return;

    if (!_speechAvailable) {
      await _initializeSpeech();
    }

    if (!_speechAvailable || _isListening) {
      return;
    }

    setState(() {
      _recognizedText = '';
      _aiResult = null;
      _statusText = 'Escuchando...';
    });

    try {
      await _speech.listen(
        localeId: 'es_PE',
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        onResult: (result) {
          if (!mounted) return;

          final words = result.recognizedWords.trim();

          setState(() {
            _recognizedText = words;
          });

          if (result.finalResult &&
              words.isNotEmpty &&
              !_isProcessing) {
            _processEmergency(words);
          }
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isListening = false;
        _statusText = 'No se pudo iniciar la escucha';
      });

      _showMessage(
        'No se pudo iniciar el micrófono: $error',
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _isListening = false;
    });

    final text = _recognizedText.trim();

    if (text.isEmpty) {
      setState(() {
        _statusText =
        'No se reconoció ninguna frase. Inténtalo nuevamente.';
      });
      return;
    }

    if (!_isProcessing) {
      await _processEmergency(text);
    }
  }

  /// Envía la frase reconocida a Gemini.
  Future<void> _processEmergency(String text) async {
    final cleanText = text.trim();

    if (_isProcessing || cleanText.isEmpty) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _isListening = false;
      _aiResult = null;
      _statusText = 'Analizando la emergencia con IA...';
    });

    try {
      await _speech.stop();

      final result = await _aiClassifier.classify(
        cleanText,
      );

      if (!mounted) return;

      setState(() {
        _aiResult = result;

        if (result.service == 'no_emergencia') {
          _statusText = 'No se detectó una emergencia';
        } else {
          _statusText =
          'Servicio recomendado: ${_serviceName(result.service)}';
        }
      });

      if (result.service == 'no_emergencia') {
        await _showNoEmergencyResult(result);
      } else {
        await _showAiRecommendation(result);
      }
    } catch (error, stackTrace) {
      debugPrint('ERROR GEMINI: $error');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      setState(() {
        _statusText =
        'No se pudo analizar la emergencia con IA';
      });

      _showMessage(
        'Error al consultar Gemini: $error',
      );
    }
     finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  Future<String?> _obtenerDistritoActual() async {
    try {
      final ubicacionActiva =
      await Geolocator.isLocationServiceEnabled();

      if (!ubicacionActiva) {
        _showMessage('Activa la ubicación de tu celular.');
        return null;
      }

      var permiso = await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        _showMessage('Debes permitir el acceso a la ubicación.');
        return null;
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final lugares = await placemarkFromCoordinates(
        posicion.latitude,
        posicion.longitude,
      );

      if (lugares.isEmpty) {
        return null;
      }

      final lugar = lugares.first;

      debugPrint('subLocality: ${lugar.subLocality}');
      debugPrint('locality: ${lugar.locality}');
      debugPrint(
        'subAdministrativeArea: ${lugar.subAdministrativeArea}',
      );

// Unimos los campos para detectar zonas conocidas.
      final ubicacionCompleta = [
        lugar.subLocality,
        lugar.locality,
        lugar.subAdministrativeArea,
      ].whereType<String>().join(' ').toLowerCase();

// San Marcos de la Aguada pertenece a Mala.
      if (ubicacionCompleta.contains('san marcos de la aguada') ||
          ubicacionCompleta.contains('san marcos')) {
        debugPrint('DISTRITO CORREGIDO: Mala');
        return 'Mala';
      }

// Universidad Autónoma del Perú / zonas de Villa El Salvador.
      if (ubicacionCompleta.contains('villa el salvador')) {
        debugPrint('DISTRITO CORREGIDO: Villa El Salvador');
        return 'Villa El Salvador';
      }

// Primero intenta obtener el distrito desde locality.
      String? distrito = lugar.locality?.trim();

// Si no aparece, intenta con subAdministrativeArea.
      if (distrito == null || distrito.isEmpty) {
        distrito = lugar.subAdministrativeArea?.trim();
      }

// Como última opción usa subLocality.
      if (distrito == null || distrito.isEmpty) {
        distrito = lugar.subLocality?.trim();
      }

      debugPrint('DISTRITO DETECTADO: $distrito');

      return distrito;
    } catch (error) {
      debugPrint('ERROR AL DETECTAR DISTRITO: $error');
      return null;
    }
  }
  Future<void> _showAiRecommendation(
      EmergencyAiResult result,
      ) async {
    final baseService = EmergencyServices.findById(
      result.service,
    );

    String? distrito;
    EmergencyContact? contactoLocal;

    try {
      // 1. Detectamos el distrito usando la ubicación.
      distrito = await _obtenerDistritoActual();

      debugPrint('Distrito que se buscará en Firebase: $distrito');

      // 2. Si detectó un distrito, busca sus servicios en Firestore.
      if (distrito != null && distrito.isNotEmpty) {
        final servicios =
        await _firestoreService.obtenerServicios(distrito);

        // Ejemplo:
        // result.service = policia
        // entonces obtiene el contacto "policia" de Firebase.
        contactoLocal = servicios[result.service];
      }
    } catch (error) {
      debugPrint('No se pudo obtener el contacto local: $error');
    }

    if (!mounted) return;

    // Si encontró el contacto en Firebase, usa sus datos.
    // Si no lo encontró, usa el número nacional.
    final nombreServicio =
        contactoLocal?.nombre ??
            baseService?.name ??
            _serviceName(result.service);

    final numeroServicio =
        contactoLocal?.telefono ??
            baseService?.number;

    final direccionServicio =
        contactoLocal?.direccion ?? '';

    if (numeroServicio == null ||
        numeroServicio.trim().isEmpty) {
      await _showLocalServiceResult(result);
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF202033),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Emergencia analizada con IA',
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: (
                        baseService?.iconColor ??
                            Colors.red
                    ).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    baseService?.icon ?? Icons.emergency,
                    size: 55,
                    color:
                    baseService?.iconColor ??
                        Colors.red,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  nombreServicio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                _InformationRow(
                  label: 'Prioridad',
                  value: result.priority.toUpperCase(),
                  valueColor: _priorityColor(
                    result.priority,
                  ),
                ),

                const SizedBox(height: 8),

                _InformationRow(
                  label: 'Confianza',
                  value:
                  '${(result.confidence * 100).toStringAsFixed(0)} %',
                ),

                const SizedBox(height: 18),

                Text(
                  result.explanation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  contactoLocal != null
                      ? 'NÚMERO DEL DISTRITO'
                      : 'NÚMERO NACIONAL',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.8,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  numeroServicio,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                if (distrito != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Distrito detectado: $distrito',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],

                if (direccionServicio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    direccionServicio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                Text(
                  'Frase reconocida:\n“$_recognizedText”',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white60,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment:
          MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('CANCELAR'),
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                final servicioParaLlamar =
                EmergencyService(
                  id: result.service,
                  name: nombreServicio,
                  number: numeroServicio,
                  icon:
                  baseService?.icon ??
                      Icons.phone,
                  description:
                  direccionServicio.isNotEmpty
                      ? direccionServicio
                      : baseService
                      ?.description ??
                      '',
                  iconColor:
                  baseService?.iconColor ??
                      Colors.red,
                );

                context.push(
                  AppRoutes.calling,
                  extra: servicioParaLlamar,
                );
              },
              icon: const Icon(Icons.phone),
              label: const Text('LLAMAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Resultado para servicios locales, como Serenazgo.
  Future<void> _showLocalServiceResult(
      EmergencyAiResult result,
      ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF202033),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Servicio local recomendado',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.security,
                color: Colors.green,
                size: 65,
              ),
              const SizedBox(height: 16),
              Text(
                _serviceName(result.service),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              _InformationRow(
                label: 'Prioridad',
                value: result.priority.toUpperCase(),
                valueColor: _priorityColor(
                  result.priority,
                ),
              ),
              const SizedBox(height: 8),
              _InformationRow(
                label: 'Confianza',
                value:
                '${(result.confidence * 100).toStringAsFixed(0)} %',
              ),
              const SizedBox(height: 18),
              Text(
                result.explanation,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              const Text(
                'Este servicio no cuenta con un número '
                    'nacional. El contacto se obtendrá desde '
                    'Firestore según tu distrito.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('CERRAR'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNoEmergencyResult(
      EmergencyAiResult result,
      ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF202033),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'No se detectó una emergencia',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                size: 55,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 18),
              Text(
                result.explanation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Frase reconocida:\n“$_recognizedText”',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                setState(() {
                  _recognizedText = '';
                  _aiResult = null;
                  _statusText =
                  'Presiona el micrófono e inténtalo nuevamente';
                });
              },
              child: const Text('REINTENTAR'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go(AppRoutes.home);
              },
              child: const Text('VER SERVICIOS'),
            ),
          ],
        );
      },
    );
  }

  String _serviceName(String serviceId) {
    switch (serviceId) {
      case 'policia':
        return 'Policía';
      case 'ambulancia':
        return 'Ambulancia';
      case 'bomberos':
        return 'Bomberos';
      case 'serenazgo':
        return 'Serenazgo';
      case 'no_emergencia':
        return 'No emergencia';
      default:
        return 'Servicio desconocido';
    }
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critica':
        return Colors.redAccent;
      case 'alta':
        return Colors.orangeAccent;
      case 'media':
        return Colors.amber;
      case 'baja':
        return Colors.greenAccent;
      default:
        return Colors.white;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _isProcessing
                          ? null
                          : () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 30,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Asistente IA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    25,
                    24,
                    30,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _isProcessing
                            ? Icons.psychology
                            : Icons.emergency_share,
                        size: 58,
                        color: _isProcessing
                            ? Colors.purpleAccent
                            : Colors.redAccent,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        '¿Qué está ocurriendo?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Describe brevemente la emergencia '
                            'para que la inteligencia artificial '
                            'recomiende el servicio adecuado.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 45),
                      GestureDetector(
                        onTap: _isProcessing
                            ? null
                            : (_isListening
                            ? _stopListening
                            : _startListening),
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 250),
                          width: 145,
                          height: 145,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isProcessing
                                ? Colors.purple
                                : _isListening
                                ? Colors.red.shade700
                                : Colors.redAccent,
                            boxShadow: [
                              BoxShadow(
                                color: (_isProcessing
                                    ? Colors.purpleAccent
                                    : Colors.redAccent)
                                    .withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: _isListening ||
                                    _isProcessing
                                    ? 38
                                    : 20,
                                spreadRadius: _isListening ||
                                    _isProcessing
                                    ? 10
                                    : 4,
                              ),
                            ],
                          ),
                          child: _isProcessing
                              ? const Padding(
                            padding: EdgeInsets.all(45),
                            child:
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 5,
                            ),
                          )
                              : Icon(
                            _isListening
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            size: 68,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        _statusText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _isListening
                              ? Colors.redAccent
                              : _isProcessing
                              ? Colors.purpleAccent
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          minHeight: 130,
                        ),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.06,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'FRASE RECONOCIDA',
                              style: TextStyle(
                                fontSize: 13,
                                letterSpacing: 2,
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _recognizedText.isEmpty
                                  ? 'Aquí aparecerá lo que digas.'
                                  : _recognizedText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 19,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_aiResult != null) ...[
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius:
                            BorderRadius.circular(20),
                            border: Border.all(
                              color:
                              Colors.purpleAccent.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'RESULTADO DE LA IA',
                                style: TextStyle(
                                  color: Colors.purpleAccent,
                                  fontSize: 13,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _serviceName(
                                  _aiResult!.service,
                                ),
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Confianza: '
                                    '${(_aiResult!.confidence * 100).toStringAsFixed(0)} %',
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (_recognizedText.isNotEmpty &&
                          !_isListening &&
                          !_isProcessing)
                        OutlinedButton.icon(
                          onPressed: () {
                            _processEmergency(
                              _recognizedText,
                            );
                          },
                          icon: const Icon(
                            Icons.psychology,
                          ),
                          label: const Text(
                            'ANALIZAR CON IA',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InformationRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}