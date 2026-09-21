import 'package:flutter/material.dart';
import 'package:altoque/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Logo de ALTOQUE - Escudo circular con rayo
class AltoqueLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AltoqueLogo({
    super.key,
    this.size = 120,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: CustomPaint(
              size: Size(size * 0.5, size * 0.6),
              painter: _LightningPainter(),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'ALTOQUE',
            style: GoogleFonts.poppins(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 4,
            ),
          ),
          Text(
            'EMERGENCIA PERÚ',
            style: GoogleFonts.inter(
              fontSize: size * 0.1,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 3,
            ),
          ),
        ],
      ],
    );
  }
}

/// Painter para el ícono de rayo
class _LightningPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFD32F2F), Color(0xFFB71C1C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    // Lightning bolt shape
    path.moveTo(size.width * 0.55, 0);
    path.lineTo(size.width * 0.15, size.height * 0.5);
    path.lineTo(size.width * 0.45, size.height * 0.5);
    path.lineTo(size.width * 0.35, size.height);
    path.lineTo(size.width * 0.85, size.height * 0.4);
    path.lineTo(size.width * 0.55, size.height * 0.4);
    path.lineTo(size.width * 0.65, 0);
    path.close();

    // Shadow
    canvas.drawShadow(path, const Color(0xFFE53935), 8, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
