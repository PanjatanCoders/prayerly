// widgets/animated_background.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const AnimatedBackground({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating particles
            ..._buildFloatingParticles(),
            
            // Pulsing circles
            ..._buildPulsingCircles(),
            
            // Islamic pattern overlay
            _buildIslamicPattern(),
            
            // Subtle gradient overlay for depth
            _buildGradientOverlay(),
          ],
        );
      },
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(12, (index) {
      final double animationOffset = (index * 0.1) % 1.0;
      final double adjustedValue = (controller.value + animationOffset) % 1.0;
      
      return Positioned(
        left: (50 + index * 30.0) % 350,
        top: 100 + (math.sin(adjustedValue * 2 * math.pi + index) * 100),
        child: Transform.rotate(
          angle: adjustedValue * 2 * math.pi,
          child: Container(
            width: 4 + (index % 3) * 2,
            height: 4 + (index % 3) * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1 + (index % 3) * 0.05),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildPulsingCircles() {
    return List.generate(4, (index) {
      final double pulseValue = math.sin(controller.value * 2 * math.pi + index) * 0.5 + 0.5;
      
      return Positioned(
        top: 150.0 + index * 120,
        right: -100 + index * 50,
        child: Transform.scale(
          scale: 0.5 + pulseValue * 0.3,
          child: Container(
            width: 150 + index * 50,
            height: 150 + index * 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2ECC71).withValues(alpha: 0.1 + pulseValue * 0.1),
                width: 2,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildIslamicPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: IslamicPatternPainter(
          animationValue: controller.value,
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.3, -0.5),
            radius: 1.5,
            colors: [
              const Color(0xFF2ECC71).withValues(alpha: 0.03),
              Colors.transparent,
              const Color(0xFF1A1A1A).withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }
}

class IslamicPatternPainter extends CustomPainter {
  final double animationValue;

  IslamicPatternPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2ECC71).withValues(alpha: 0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw geometric Islamic patterns
    _drawGeometricPattern(canvas, size, paint);
    _drawStarPattern(canvas, size, paint);
  }

  void _drawGeometricPattern(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = 100 * (0.8 + math.sin(animationValue * 2 * math.pi) * 0.2);

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (animationValue * math.pi / 4);
      final x1 = centerX + math.cos(angle) * radius;
      final y1 = centerY + math.sin(angle) * radius;
      final x2 = centerX + math.cos(angle + math.pi) * radius;
      final y2 = centerY + math.sin(angle + math.pi) * radius;
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  void _drawStarPattern(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width * 0.8;
    final centerY = size.height * 0.2;
    final radius = 50;
    
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (animationValue * math.pi * 2);
      final outerRadius = i % 2 == 0 ? radius : radius * 0.5;
      final x = centerX + math.cos(angle) * outerRadius;
      final y = centerY + math.sin(angle) * outerRadius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}