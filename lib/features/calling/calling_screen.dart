import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altoque/core/theme/app_text_styles.dart';
import 'package:altoque/core/constants/emergency_services.dart';
import 'package:altoque/core/router/app_router.dart';
import 'package:altoque/features/calling/widgets/pulse_animation.dart';
import 'package:altoque/shared/widgets/gradient_button.dart';
import 'package:altoque/core/theme/app_colors.dart';

/// Pantalla de llamada en curso con CUENTA REGRESIVA CONFIGURABLE
class CallingScreen extends StatefulWidget {
  final EmergencyService service;

  const CallingScreen({super.key, required this.service});

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  String _currentAddress = 'Obteniendo dirección...';
  bool _isLoadingAddress = true;
  int _secondsRemaining = 6;
  Timer? _countdownTimer;
  bool _callLaunched = false;

  @override
  void initState() {
    super.initState();
    _initFlow();
    _getUserAddress();
  }

  Future<void> _initFlow() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _secondsRemaining = prefs.getInt('callDelay') ?? 6;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _countdownTimer?.cancel();
        if (!_callLaunched) {
          _makePhoneCall();
          _callLaunched = true;
        }
      }
    });
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: widget.service.number,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _getUserAddress() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = '${place.street}, ${place.locality}, ${place.administrativeArea}';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'No se pudo obtener la dirección exacta.';
        _isLoadingAddress = false;
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final mins = (0).toString().padLeft(2, '0');
    final secs = _secondsRemaining.toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 1),
              Text(
                'DILE ESTA UBICACIÓN AL OPERADOR:',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      if (_isLoadingAddress)
                        const CircularProgressIndicator()
                      else
                        Text(
                          _currentAddress.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayMedium.copyWith(
                            fontSize: 24,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ).animate().scale(duration: 400.ms),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volume_up_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'USA EL ALTAVOZ PARA VER ESTA PANTALLA',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.orange),
                  ),
                ],
              ).animate(delay: 1.seconds).fadeIn(),
              
              const Spacer(flex: 1),
              Text(
                'LLAMANDO A ${widget.service.name}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              ),

              const Spacer(flex: 1),
              PulseAnimation(
                color: widget.service.iconColor,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        widget.service.iconColor,
                        widget.service.iconColor.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.service.iconColor.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.service.icon,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 40),
              
              // Temporizador de cuenta regresiva
              Text(
                _formattedTime,
                style: AppTextStyles.timerText.copyWith(
                  color: _secondsRemaining == 0 ? Colors.green : Colors.white,
                ),
              ).animate(key: ValueKey(_secondsRemaining)).scale(duration: 200.ms),
              
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: GradientButton(
                  text: 'CANCELAR',
                  icon: Icons.call_end_rounded,
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ).animate(delay: 800.ms).fadeIn(duration: 400.ms).slideY(begin: 0.5, end: 0),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
