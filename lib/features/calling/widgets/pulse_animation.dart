import 'package:flutter/material.dart';

/// Widget de animación de pulso concéntrico
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Color color;
  final int pulseCount;

  const PulseAnimation({
    super.key,
    required this.child,
    required this.color,
    this.pulseCount = 3,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.pulseCount,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    // Iniciar cada pulso con un delay escalonado
    for (int i = 0; i < widget.pulseCount; i++) {
      Future.delayed(Duration(milliseconds: 600 * i), () {
        if (mounted) {
          _controllers[i].repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anillos de pulso
          ...List.generate(widget.pulseCount, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Container(
                  width: 120 + (80 * _animations[index].value),
                  height: 120 + (80 * _animations[index].value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color
                          .withValues(alpha: 0.4 * (1 - _animations[index].value)),
                      width: 2,
                    ),
                  ),
                );
              },
            );
          }),
          // Widget central (ícono)
          widget.child,
        ],
      ),
    );
  }
}
