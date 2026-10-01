import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../utils/circular_progress_painter.dart';
import '../utils/moon_phase.dart';
import '../utils/moon_phase_painter.dart';
import '../utils/sun_position.dart';
import '../utils/theme/app_theme.dart';

/// The countdown ring: a plain disc with an orange progress ring, a sky icon,
/// the next prayer's name, and an HH:MM:SS countdown.
///
/// The sky icon is not just a flat sun-or-moon swap: by day its color and
/// glow follow [SunPosition.intensity] (pale and dim at dawn/dusk, hot and
/// bright at Dhuhr) and it is overlaid with clouds when [weather] reports
/// real cloud cover; by night it draws the moon's actual current phase (via
/// [MoonPhase]/[MoonPhasePainter]) sized and glowing according to how much
/// of it is lit, also dimmed under cloud cover.
class CircularTimerWidget extends StatefulWidget {
  final String nextPrayer;
  final Duration timeRemaining;
  final DateTime currentTime;
  final double progress;
  final Map<String, DateTime> prayerTimes;
  final WeatherSnapshot? weather;
  final double size;

  const CircularTimerWidget({
    super.key,
    required this.nextPrayer,
    required this.timeRemaining,
    required this.currentTime,
    required this.progress,
    required this.prayerTimes,
    this.weather,
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
                    _SkyIcon(
                      sun: sun,
                      weather: widget.weather,
                      currentTime: widget.currentTime,
                      size: widget.size * 0.165,
                    ),
                    SizedBox(height: widget.size * 0.035),
                    Text(
                      widget.nextPrayer,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: widget.size * 0.106,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTimeRemaining(widget.timeRemaining),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: widget.size * 0.118,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'until prayer',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.5),
                        fontSize: widget.size * 0.065,
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

/// Renders the sun (by day) or the real current moon phase (by night),
/// adjusted for cloud cover.
class _SkyIcon extends StatelessWidget {
  final SunPosition sun;
  final WeatherSnapshot? weather;
  final DateTime currentTime;
  final double size;

  const _SkyIcon({
    required this.sun,
    required this.weather,
    required this.currentTime,
    required this.size,
  });

  // Above this, the sky is drawn mostly as cloud with the sun/moon barely
  // visible behind it; above the lower threshold, a smaller cloud is laid
  // over an otherwise-normal sun/moon.
  static const _overcastThreshold = 0.7;
  static const _partlyCloudyThreshold = 0.3;

  @override
  Widget build(BuildContext context) {
    final cloudFraction = weather?.cloudFraction ?? 0.0;
    final isPrecipitating = weather?.isPrecipitating ?? false;
    final isOvercast = isPrecipitating || cloudFraction > _overcastThreshold;
    final isPartlyCloudy = !isOvercast && cloudFraction > _partlyCloudyThreshold;

    final body = sun.isSun ? _buildSun(isOvercast) : _buildMoon(isOvercast);

    if (!isPartlyCloudy && !isOvercast) return body;

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: isOvercast ? 0.35 : 0.85, child: body),
        Positioned(
          right: -size * 0.16,
          bottom: -size * 0.04,
          child: Icon(
            isPrecipitating ? Icons.grain : Icons.cloud,
            color: Colors.blueGrey.shade300,
            size: size * (isOvercast ? 0.95 : 0.62),
          ),
        ),
      ],
    );
  }

  /// Color and glow follow [SunPosition.intensity] directly, so the same
  /// "sun" icon actually looks pale and dim near Fajr/Maghrib and hot and
  /// bright at Dhuhr, rather than a single flat amber regardless of time of
  /// day.
  Widget _buildSun(bool isOvercast) {
    final intensity = sun.intensity.clamp(0.0, 1.0);
    final sunColor = Color.lerp(
      const Color(0xFFFFE28A),
      AppTheme.primaryOrange,
      intensity,
    )!;
    final glowAlpha = (0.15 + intensity * 0.35) * (isOvercast ? 0.3 : 1.0);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: sunColor.withValues(alpha: glowAlpha.clamp(0.0, 1.0)),
            blurRadius: size * (0.5 + intensity * 0.6),
            spreadRadius: size * 0.08,
          ),
        ],
      ),
      child: Icon(
        Icons.wb_sunny,
        color: sunColor.withValues(alpha: isOvercast ? 0.45 : 1.0),
        size: size,
      ),
    );
  }

  /// Draws the real current moon phase (see [MoonPhase]/[MoonPhasePainter])
  /// rather than one flat crescent icon: a full moon renders visibly larger
  /// and with a brighter glow than a new or crescent moon, and the night
  /// itself reads as brighter the fuller the moon is.
  Widget _buildMoon(bool isOvercast) {
    final moon = MoonPhase.forDate(currentTime);
    final diameter = size * (0.82 + moon.illumination * 0.36);
    final glowAlpha = (0.08 + moon.illumination * 0.3) * (isOvercast ? 0.25 : 1.0);

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBFC9FF).withValues(alpha: glowAlpha.clamp(0.0, 1.0)),
            blurRadius: diameter * 0.6,
            spreadRadius: diameter * 0.08,
          ),
        ],
      ),
      child: Opacity(
        opacity: isOvercast ? 0.5 : 1.0,
        child: ClipOval(
          child: CustomPaint(
            size: Size(diameter, diameter),
            painter: MoonPhasePainter(
              illumination: moon.illumination,
              isWaxing: moon.isWaxing,
              litColor: const Color(0xFFF2F3FA),
              darkColor: const Color(0xFF232A52),
            ),
          ),
        ),
      ),
    );
  }
}
