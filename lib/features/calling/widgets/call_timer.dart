import 'dart:async';
import 'package:flutter/material.dart';
import 'package:altoque/core/theme/app_text_styles.dart';

/// Widget de temporizador de llamada
class CallTimer extends StatefulWidget {
  const CallTimer({super.key});

  @override
  State<CallTimer> createState() => _CallTimerState();
}

class _CallTimerState extends State<CallTimer> {
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedTime,
      style: AppTextStyles.timerText,
    );
  }
}
