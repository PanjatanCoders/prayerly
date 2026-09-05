// widgets/compass/compass_widget.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/qibla_data.dart';
import '../../services/compass_service.dart';

/// A rotating Qibla dial.
///
/// The previous implementation kept the dial fixed and rotated only the Qibla
/// marker, so "N" always pointed at the top of the screen no matter which way
/// the phone faced - it looked like a compass but could not be used as one.
/// Here the whole rose counter-rotates with the device heading, exactly as a
/// physical compass card does, and a fixed index at 12 o'clock marks the
/// direction the user is facing.
///
/// Everything is drawn by a single [CustomPainter] rather than a stack of
/// dozens of rotated widgets, so a 25 Hz sensor feed costs one repaint instead
/// of a full layout pass.
class CompassWidget extends StatefulWidget {
  final QiblaReading reading;
  final double size;

  const CompassWidget({
    super.key,
    required this.reading,
    this.size = 300,
  });

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  /// Heading as a continuously accumulating value rather than one wrapped to
  /// 0-360. Interpolating a wrapped angle makes the dial spin the long way
  /// round every time the user crosses north; accumulating the shortest delta
  /// removes the discontinuity entirely.
  double _unwrappedHeading = 0;
  double? _lastHeading;
  bool _wasAligned = false;

  @override
  void initState() {
    super.initState();
    _syncHeading();
  }

  @override
  void didUpdateWidget(covariant CompassWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncHeading();
    _reportAlignmentChange();
  }

  void _syncHeading() {
    final heading = widget.reading.heading;
    if (heading == null) return;

    final previous = _lastHeading;
    if (previous == null) {
      _unwrappedHeading = heading;
    } else {
      _unwrappedHeading += CompassService.shortestDelta(previous, heading);
    }
    _lastHeading = heading;
  }

  /// A short buzz the moment the user lines up, so they do not have to keep
  /// watching the screen while turning.
  void _reportAlignmentChange() {
    final aligned = widget.reading.isAligned;
    if (aligned && !_wasAligned) {
      HapticFeedback.mediumImpact();
    }
    _wasAligned = aligned;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reading = widget.reading;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: _unwrappedHeading),
        // Long enough to hide sensor jitter, short enough to feel direct.
        duration: const Duration(milliseconds: 120),
        curve: Curves.linear,
        builder: (context, animatedHeading, _) {
          return CustomPaint(
            painter: _CompassPainter(
              headingDegrees: reading.hasHeading ? animatedHeading : 0,
              qiblaBearing: reading.qiblaBearing,
              isAligned: reading.isAligned,
              hasHeading: reading.hasHeading,
              dialColor: theme.colorScheme.surfaceContainerHighest,
              onDialColor: theme.colorScheme.onSurface,
              mutedColor: theme.colorScheme.onSurfaceVariant,
              alignedColor: const Color(0xFF2E9E5B),
              qiblaColor: const Color(0xFFFFB300),
              northColor: const Color(0xFFE53935),
            ),
            size: Size.square(widget.size),
          );
        },
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double headingDegrees;
  final double qiblaBearing;
  final bool isAligned;
  final bool hasHeading;

  final Color dialColor;
  final Color onDialColor;
  final Color mutedColor;
  final Color alignedColor;
  final Color qiblaColor;
  final Color northColor;

  _CompassPainter({
    required this.headingDegrees,
    required this.qiblaBearing,
    required this.isAligned,
    required this.hasHeading,
    required this.dialColor,
    required this.onDialColor,
    required this.mutedColor,
    required this.alignedColor,
    required this.qiblaColor,
    required this.northColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    _paintFace(canvas, center, radius);

    // The rose counter-rotates: turning the phone right sweeps the card left,
    // leaving north physically fixed.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-_rad(headingDegrees));

    _paintTicks(canvas, radius);
    _paintCardinalLabels(canvas, radius);
    _paintQiblaNeedle(canvas, radius);

    canvas.restore();

    _paintIndex(canvas, center, radius);
    _paintHub(canvas, center);
  }

  // ---------------------------------------------------------------------------

  void _paintFace(Canvas canvas, Offset center, double radius) {
    final face = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(dialColor, Colors.white, 0.06)!,
          dialColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 2, face);

    // The rim turns green as confirmation the moment the user is on target.
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isAligned ? 4 : 2
      ..color = isAligned ? alignedColor : mutedColor.withValues(alpha: 0.35);
    canvas.drawCircle(center, radius - 2, rim);

    if (isAligned) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = alignedColor.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, radius - 6, glow);
    }
  }

  void _paintTicks(Canvas canvas, double radius) {
    final minor = Paint()
      ..strokeWidth = 1
      ..color = mutedColor.withValues(alpha: 0.35);
    final major = Paint()
      ..strokeWidth = 2
      ..color = onDialColor.withValues(alpha: 0.7);

    for (int degree = 0; degree < 360; degree += 5) {
      final isMajor = degree % 45 == 0;
      final outer = radius - 8;
      final inner = outer - (isMajor ? 14 : 6);
      canvas.drawLine(
        _polar(degree.toDouble(), inner),
        _polar(degree.toDouble(), outer),
        isMajor ? major : minor,
      );
    }
  }

  void _paintCardinalLabels(Canvas canvas, double radius) {
    const primary = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    const secondary = {45: 'NE', 135: 'SE', 225: 'SW', 315: 'NW'};

    primary.forEach((degree, label) {
      _paintRotatedLabel(
        canvas,
        label: label,
        bearing: degree.toDouble(),
        radius: radius - 38,
        style: TextStyle(
          color: degree == 0 ? northColor : onDialColor,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      );
    });

    secondary.forEach((degree, label) {
      _paintRotatedLabel(
        canvas,
        label: label,
        bearing: degree.toDouble(),
        radius: radius - 37,
        style: TextStyle(
          color: mutedColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
    });
  }

  /// Draws a label at [bearing] and counter-rotates it so the text stays
  /// upright as the dial turns.
  void _paintRotatedLabel(
    Canvas canvas, {
    required String label,
    required double bearing,
    required double radius,
    required TextStyle style,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final position = _polar(bearing, radius);

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(_rad(headingDegrees));
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  void _paintQiblaNeedle(Canvas canvas, double radius) {
    // Far enough in that the Kaaba marker never overlaps the cardinal
    // labels as it sweeps past them.
    final tipRadius = radius - 74;
    final tip = _polar(qiblaBearing, tipRadius);
    final color = isAligned ? alignedColor : qiblaColor;

    // Shaft from the hub out to the Kaaba marker.
    canvas.drawLine(
      Offset.zero,
      tip,
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: hasHeading ? 0.95 : 0.4),
    );

    // Counterweight tail, so the needle reads as a needle and not an arrow
    // that could be mistaken for north.
    canvas.drawLine(
      Offset.zero,
      _polar(qiblaBearing + 180, radius * 0.28),
      Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = mutedColor.withValues(alpha: 0.45),
    );

    // Kaaba marker.
    const markerRadius = 19.0;
    canvas.drawCircle(
      tip,
      markerRadius + 3,
      Paint()..color = color.withValues(alpha: 0.22),
    );
    canvas.drawCircle(tip, markerRadius, Paint()..color = color);
    canvas.drawCircle(
      tip,
      markerRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.9),
    );

    _paintKaabaGlyph(canvas, tip);
  }

  /// A small cube with its band, drawn rather than taken from an icon font so
  /// it survives icon tree-shaking in release builds.
  void _paintKaabaGlyph(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Keep the glyph upright while the dial underneath rotates.
    canvas.rotate(_rad(headingDegrees));

    const half = 8.0;
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTRB(-half, -half, half, half),
      const Radius.circular(2),
    );
    canvas.drawRRect(body, Paint()..color = Colors.black87);
    canvas.drawRect(
      const Rect.fromLTRB(-half, -3, half, 0),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    canvas.restore();
  }

  /// Fixed triangle at 12 o'clock: the direction the phone itself is pointing.
  void _paintIndex(Canvas canvas, Offset center, double radius) {
    final color = isAligned ? alignedColor : onDialColor;
    final top = center.dy - radius + 2;

    // Points down, into the dial, marking the direction the phone faces.
    final path = Path()
      ..moveTo(center.dx, top + 16)
      ..lineTo(center.dx - 9, top)
      ..lineTo(center.dx + 9, top)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  void _paintHub(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 8, Paint()..color = onDialColor);
    canvas.drawCircle(
      center,
      4,
      Paint()..color = isAligned ? alignedColor : qiblaColor,
    );
  }

  /// Point at [bearing] degrees clockwise from north, [radius] from centre,
  /// in a canvas already translated to the dial's centre.
  static Offset _polar(double bearing, double radius) {
    final radians = _rad(bearing);
    return Offset(radius * math.sin(radians), -radius * math.cos(radians));
  }

  static double _rad(double degrees) => degrees * math.pi / 180;

  @override
  bool shouldRepaint(covariant _CompassPainter old) {
    return old.headingDegrees != headingDegrees ||
        old.qiblaBearing != qiblaBearing ||
        old.isAligned != isAligned ||
        old.hasHeading != hasHeading ||
        old.dialColor != dialColor;
  }
}
