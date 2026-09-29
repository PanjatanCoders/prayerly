// ignore_for_file: sized_box_for_whitespace

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../utils/circular_progress_painter.dart';
import '../utils/solar_angle.dart';
import '../utils/sun_position.dart';
import '../utils/theme/app_theme.dart';

/// The countdown ring, doubling as a live sun/moon sky-arc gauge: a marker
/// travels along a horizon-to-zenith-to-horizon path based on today's actual
/// Fajr/Sunrise/Dhuhr/Maghrib/Isha times, so its angle always means "how far
/// from sunrise to overhead" rather than a fixed clock reading. The angle
/// printed in the caption, however, is the sun's real elevation/azimuth (see
/// [SolarAngle]) - the marker's position is a stylized gauge, but the number
/// underneath it is true astronomy.
class CircularTimerWidget extends StatefulWidget {
  final String nextPrayer;
  final Duration timeRemaining;
  final DateTime currentTime;
  final double progress;
  final Map<String, DateTime> prayerTimes;
  final double latitude;
  final double longitude;
  final double size;

  const CircularTimerWidget({
    super.key,
    required this.nextPrayer,
    required this.timeRemaining,
    required this.currentTime,
    required this.progress,
    required this.prayerTimes,
    required this.latitude,
    required this.longitude,
    this.size = 190,
  });

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget>
    with TickerProviderStateMixin {
  // Below this, the ring gets a gentle "hurry up" pulse; below this, adhan is
  // imminent and the pulse quickens and warms towards amber.
  static const _pulseThreshold = Duration(minutes: 10);
  static const _urgentThreshold = Duration(minutes: 1);

  late final AnimationController _pulseController;
  // Slow breathing glow behind the sun/moon marker itself.
  late final AnimationController _glowController;
  // Twinkle cycle for the night sky's stars.
  late final AnimationController _twinkleController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _syncPulse();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void didUpdateWidget(CircularTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  bool get _isPulsing => widget.timeRemaining <= _pulseThreshold;
  bool get _isUrgent => widget.timeRemaining <= _urgentThreshold;

  void _syncPulse() {
    final targetDuration = _isUrgent
        ? const Duration(milliseconds: 550)
        : const Duration(milliseconds: 1100);
    if (_pulseController.duration != targetDuration) {
      _pulseController.duration = targetDuration;
    }
    if (_isPulsing) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else if (_pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final sun = SunPosition.calculate(widget.prayerTimes, widget.currentTime);
    final sky = _SkyTheme.forBrightness(sun.brightness);
    final solarAngle = SolarAngle.calculate(
      latitude: widget.latitude,
      longitude: widget.longitude,
      time: widget.currentTime,
    );
    final urgentColor = AppTheme.legibleAccent(context, AppTheme.primaryAmber);
    final discSize = widget.size - 30;
    final arcRadius = discSize / 2 * 0.62;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _twinkleController]),
      builder: (context, child) {
        final t = _isPulsing ? _pulseController.value : 0.0;
        final ringColor = AppTheme.legibleAccent(
          context,
          _isUrgent ? Color.lerp(sky.ringColor, urgentColor, t)! : sky.ringColor,
        );
        final scale = _isPulsing ? 1.0 + (t * 0.035) : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: _isPulsing
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ringColor.withValues(alpha: 0.25 * t),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  )
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Sky disc: the backdrop that actually carries the
                // day/night read at a glance, independent of the ring.
                Container(
                  width: discSize,
                  height: discSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: sky.discGradient),
                  ),
                ),

                if (sun.brightness == SkyBrightness.night)
                  CustomPaint(
                    size: Size(discSize, discSize),
                    painter: _StarfieldPainter(twinkle: _twinkleController.value),
                  ),

                CustomPaint(
                  size: Size(discSize, discSize),
                  painter: _SkyArcPainter(
                    radius: arcRadius,
                    color: onSurface.withValues(alpha: 0.35),
                  ),
                ),

                // The marker travels smoothly between its last angle and
                // its newly computed one each time the parent ticks, rather
                // than snapping - this is the "rotation" across the sky.
                TweenAnimationBuilder<double>(
                  key: ValueKey(sun.isSun),
                  tween: Tween<double>(begin: sun.angleDegrees, end: sun.angleDegrees),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  builder: (context, animatedAngle, _) {
                    final phi = animatedAngle * math.pi / 180;
                    final dx = -math.cos(phi) * arcRadius;
                    final dy = -math.sin(phi) * arcRadius;
                    final glow = 0.55 + 0.45 * _glowController.value;

                    return Transform.translate(
                      offset: Offset(dx, dy),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: sky.glowColor.withValues(
                                alpha: (sun.isSun ? 0.55 : 0.35) * glow,
                              ),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(sky.icon, color: sky.glyphColor, size: 20),
                      ),
                    );
                  },
                ),

                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: CircularProgressPainter(
                    progress: widget.progress,
                    color: ringColor,
                  ),
                ),

                Positioned(
                  bottom: discSize * 0.12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.nextPrayer,
                        style: TextStyle(
                          color: ringColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTimeRemaining(widget.timeRemaining),
                        style: TextStyle(
                          color: sky.glyphColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${solarAngle.altitudeDegrees.round()}° • ${solarAngle.compassDirection}',
                        style: TextStyle(
                          color: sky.glyphColor.withValues(alpha: 0.75),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Formats time remaining as HH:MM:SS
  String _formatTimeRemaining(Duration duration) {
    return "${duration.inHours.toString().padLeft(2, '0')}:"
        "${(duration.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }
}

/// Visual language for one [SkyBrightness] tier.
class _SkyTheme {
  final IconData icon;
  final Color glyphColor;
  final Color glowColor;
  final Color ringColor;
  final List<Color> discGradient;
  final String label;

  const _SkyTheme({
    required this.icon,
    required this.glyphColor,
    required this.glowColor,
    required this.ringColor,
    required this.discGradient,
    required this.label,
  });

  factory _SkyTheme.forBrightness(SkyBrightness brightness) {
    switch (brightness) {
      case SkyBrightness.night:
        return const _SkyTheme(
          icon: Icons.nightlight_round,
          glyphColor: Color(0xFFE8EAFF),
          glowColor: Color(0xFF7986CB),
          ringColor: Color(0xFF5C6BC0),
          discGradient: [Color(0xFF1A2148), Color(0xFF0A0E24)],
          label: 'Night',
        );
      case SkyBrightness.dim:
        return const _SkyTheme(
          icon: Icons.wb_twilight,
          glyphColor: Color(0xFFFFD180),
          glowColor: Color(0xFFFF8A65),
          ringColor: Color(0xFFFF8A65),
          discGradient: [Color(0xFF4A3465), Color(0xFF221A3B)],
          label: 'Soft light',
        );
      case SkyBrightness.medium:
        return const _SkyTheme(
          icon: Icons.wb_sunny_outlined,
          glyphColor: Color(0xFFFFE082),
          glowColor: Color(0xFFFFB300),
          ringColor: Color(0xFF42A5F5),
          discGradient: [Color(0xFF1976D2), Color(0xFF0D47A1)],
          label: 'Medium light',
        );
      case SkyBrightness.bright:
        return const _SkyTheme(
          icon: Icons.wb_sunny,
          glyphColor: Color(0xFFFFF8E1),
          glowColor: Color(0xFFFFD54F),
          ringColor: Color(0xFFFFB300),
          discGradient: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
          label: 'Very bright',
        );
    }
  }
}

/// The horizon line and the guide arc the sun/moon marker travels along.
class _SkyArcPainter extends CustomPainter {
  final double radius;
  final Color color;

  _SkyArcPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final horizonPaint = Paint()
      ..color = color
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      horizonPaint,
    );

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    // West -> north (top) -> east: the sun/moon's actual path overhead.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SkyArcPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}

/// A sparse field of fixed-position stars, above the horizon line only, that
/// twinkle out of phase with each other, driven by a single 0..1 [twinkle].
class _StarfieldPainter extends CustomPainter {
  final double twinkle;

  _StarfieldPainter({required this.twinkle});

  static const _stars = [
    Offset(0.22, 0.16),
    Offset(0.50, 0.08),
    Offset(0.78, 0.18),
    Offset(0.34, 0.32),
    Offset(0.66, 0.30),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _stars.length; i++) {
      final phase = (twinkle + (i / _stars.length)) % 1.0;
      final opacity = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(phase * 2 * math.pi));
      final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
      final offset = Offset(_stars[i].dx * size.width, _stars[i].dy * size.height);
      canvas.drawCircle(offset, 1.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) =>
      oldDelegate.twinkle != twinkle;
}
