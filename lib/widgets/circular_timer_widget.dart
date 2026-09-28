// ignore_for_file: sized_box_for_whitespace

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../utils/circular_progress_painter.dart';
import '../utils/sun_position.dart';
import '../utils/theme/app_theme.dart';

/// The countdown ring, now doubling as a live sun/moon gauge: the disc
/// behind the ring, the glyph in the center and its glow all track today's
/// actual sunrise/Dhuhr/Maghrib times rather than a fixed clock, so "very
/// bright" always lands around solar noon regardless of season or location.
class CircularTimerWidget extends StatefulWidget {
  final String nextPrayer;
  final Duration timeRemaining;
  final DateTime currentTime;
  final double progress;
  final Map<String, DateTime> prayerTimes;
  final double size;

  const CircularTimerWidget({
    super.key,
    required this.nextPrayer,
    required this.timeRemaining,
    required this.currentTime,
    required this.progress,
    required this.prayerTimes,
    this.size = 180,
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
  // Slow continuous spin for the sunbeam sweep behind a very bright sun.
  late final AnimationController _rayController;
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

    _rayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();

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
    _rayController.dispose();
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
    final urgentColor = AppTheme.legibleAccent(context, AppTheme.primaryAmber);

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_pulseController, _rayController, _twinkleController]),
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
                  width: widget.size - 30,
                  height: widget.size - 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: sky.discGradient,
                    ),
                  ),
                ),

                if (sun.brightness == SkyBrightness.night)
                  CustomPaint(
                    size: Size(widget.size - 30, widget.size - 30),
                    painter: _StarfieldPainter(twinkle: _twinkleController.value),
                  ),

                if (sun.brightness == SkyBrightness.bright)
                  Transform.rotate(
                    angle: _rayController.value * 2 * math.pi,
                    child: CustomPaint(
                      size: Size(widget.size - 30, widget.size - 30),
                      painter: _SunburstPainter(color: sky.glowColor),
                    ),
                  ),

                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: CircularProgressPainter(
                    progress: widget.progress,
                    color: ringColor,
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(sky.icon, color: sky.glyphColor, size: 26, shadows: [
                      Shadow(color: sky.glowColor.withValues(alpha: 0.8), blurRadius: 14),
                    ]),
                    const SizedBox(height: 2),
                    Text(
                      widget.nextPrayer,
                      style: TextStyle(
                        color: ringColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimeRemaining(widget.timeRemaining),
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      sky.label,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.55),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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

/// A sparse field of fixed-position stars that twinkle out of phase with
/// each other, driven by a single 0..1 [twinkle] value.
class _StarfieldPainter extends CustomPainter {
  final double twinkle;

  _StarfieldPainter({required this.twinkle});

  static const _stars = [
    Offset(0.28, 0.26),
    Offset(0.68, 0.20),
    Offset(0.78, 0.55),
    Offset(0.22, 0.62),
    Offset(0.50, 0.72),
    Offset(0.62, 0.38),
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

/// Faint radiating sunbeams behind a "very bright" sun, slowly rotating.
class _SunburstPainter extends CustomPainter {
  final Color color;

  _SunburstPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.55;
    const beamCount = 12;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < beamCount; i++) {
      final angle = (2 * math.pi / beamCount) * i;
      final start = center + Offset(math.cos(angle), math.sin(angle)) * innerRadius;
      final end = center + Offset(math.cos(angle), math.sin(angle)) * outerRadius;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) =>
      oldDelegate.color != color;
}
