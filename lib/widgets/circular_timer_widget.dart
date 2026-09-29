import 'package:flutter/material.dart';
import '../utils/circular_progress_painter.dart';
import '../utils/sun_position.dart';
import '../utils/theme/app_theme.dart';

/// The countdown ring: a plain disc with an orange progress ring, a sun/moon
/// icon (picked from today's actual Fajr/Sunrise/Dhuhr/Maghrib/Isha times via
/// [SunPosition] - no real astronomy needed just to know day vs. night), the
/// next prayer's name, and an HH:MM:SS countdown.
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
    this.size = 190,
  });

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget>
    with SingleTickerProviderStateMixin {
  // Below this, the ring gets a gentle "hurry up" pulse; below this, adhan is
  // imminent and the pulse quickens and warms towards amber.
  static const _pulseThreshold = Duration(minutes: 10);
  static const _urgentThreshold = Duration(minutes: 1);

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(CircularTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
    final sun = SunPosition.calculate(widget.prayerTimes, widget.currentTime);
    final icon = sun.isSun ? Icons.wb_sunny : Icons.nightlight_round;
    final iconColor = sun.isSun ? AppTheme.primaryAmber : const Color(0xFF5C6BC0);
    final ringColor = AppTheme.legibleAccent(context, AppTheme.primaryAmber);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final t = _isPulsing ? _pulseController.value : 0.0;
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
                Container(
                  width: widget.size - 12,
                  height: widget.size - 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: iconColor, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      widget.nextPrayer,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTimeRemaining(widget.timeRemaining),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'until prayer',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.5),
                        fontSize: 11,
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
