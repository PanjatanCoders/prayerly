import 'package:flutter/material.dart';

/// Draws the moon disc shaped to its real current phase (crescent, quarter,
/// gibbous, full) instead of a single flat icon, using the classic
/// "half-disc plus a centered ellipse" technique:
///
/// 1. Fill the whole disc dark.
/// 2. Fill the half that's permanently on the lit side (right if waxing,
///    left if waning) with the lit color.
/// 3. For a crescent ([illumination] < 0.5), paint a dark ellipse over the
///    middle to shrink that half down to a sliver as illumination falls to 0.
/// 4. For a gibbous ([illumination] > 0.5), paint a lit ellipse over the
///    middle to grow brightness into the other half as illumination rises
///    to 1 (full moon).
///
/// The ellipse is centered either way, so the same shapes work for waxing
/// and waning without extra branching: the half that's already the right
/// color is simply painted over itself with no visible change.
class MoonPhasePainter extends CustomPainter {
  final double illumination;
  final bool isWaxing;
  final Color litColor;
  final Color darkColor;

  const MoonPhasePainter({
    required this.illumination,
    required this.isWaxing,
    required this.litColor,
    required this.darkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circleRect = Rect.fromCircle(center: center, radius: radius);
    final k = illumination.clamp(0.0, 1.0);

    canvas.save();
    canvas.clipPath(Path()..addOval(circleRect));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = darkColor,
    );

    final litHalfRect = isWaxing
        ? Rect.fromLTRB(center.dx, circleRect.top, circleRect.right, circleRect.bottom)
        : Rect.fromLTRB(circleRect.left, circleRect.top, center.dx, circleRect.bottom);
    canvas.drawRect(litHalfRect, Paint()..color = litColor);

    if (k < 0.5) {
      final horizontalRadius = radius * (1 - 2 * k);
      if (horizontalRadius > 0.5) {
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: horizontalRadius * 2,
            height: radius * 2,
          ),
          Paint()..color = darkColor,
        );
      }
    } else if (k > 0.5) {
      final horizontalRadius = radius * (2 * k - 1);
      if (horizontalRadius > 0.5) {
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: horizontalRadius * 2,
            height: radius * 2,
          ),
          Paint()..color = litColor,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MoonPhasePainter oldDelegate) =>
      oldDelegate.illumination != illumination ||
      oldDelegate.isWaxing != isWaxing ||
      oldDelegate.litColor != litColor ||
      oldDelegate.darkColor != darkColor;
}
