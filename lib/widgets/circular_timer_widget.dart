import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/location_data.dart';
import '../services/weather_service.dart';
import '../utils/circular_progress_painter.dart';
import '../utils/moon_phase.dart';
import '../utils/moon_phase_painter.dart';
import '../utils/sun_position.dart';
import '../utils/theme/app_theme.dart';
import 'world_map_dialog.dart';

/// Where to draw the sun/moon along the sky disc's upper arc for a given
/// [SunPosition.angleDegrees] (0 = horizon/rising, 90 = zenith, 180 =
/// horizon/setting), as an offset from the disc's center.
///
/// The vertical sweep is compressed to `[baseLift*radius, radius]` rather
/// than the full `[0, radius]` so the body never drops to the same height as
/// the centered countdown text, even right at sunrise/sunset/moonrise/
/// moonset - it stays a "sky arc" confined to the upper part of the disc.
Offset _skyArcOffset(double angleDegrees, double radius) {
  const baseLift = 0.35;
  final rad = angleDegrees.clamp(0.0, 180.0) * math.pi / 180.0;
  final sweep = math.sin(rad);
  final dx = -math.cos(rad) * radius * 0.9;
  final dy = -(baseLift + sweep * (1 - baseLift)) * radius;
  return Offset(dx, dy);
}

/// The countdown ring: a globe disc (lit on whichever side faces the
/// orbiting sun/moon icon) inside an orange progress ring. Purely visual -
/// the next prayer's name and countdown text live on the side card now (see
/// [InfoCardWidget]), not overlaid on the circle itself. Tapping it opens
/// [showWorldMapDialog] - the same map, full and unpanned, plus live
/// numbers.
///
/// The sky icon is not just a flat sun-or-moon swap: by day its color and
/// glow follow [SunPosition.intensity] (pale and dim at dawn/dusk, hot and
/// bright at Dhuhr) and it is overlaid with clouds when [weather] reports
/// real cloud cover; by night it draws the moon's actual current phase (via
/// [MoonPhase]/[MoonPhasePainter]) sized and glowing according to how much
/// of it is lit, also dimmed under cloud cover.
class CircularTimerWidget extends StatefulWidget {
  final Duration timeRemaining;
  final DateTime currentTime;
  final double progress;
  final Map<String, DateTime> prayerTimes;
  final WeatherSnapshot? weather;
  final LocationData? locationData;
  final double size;

  const CircularTimerWidget({
    super.key,
    required this.timeRemaining,
    required this.currentTime,
    required this.progress,
    required this.prayerTimes,
    this.weather,
    this.locationData,
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

  void _openWorldMap() {
    showWorldMapDialog(
      context,
      locationData: widget.locationData,
      prayerTimes: widget.prayerTimes,
      currentTime: widget.currentTime,
      weather: widget.weather,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sun = SunPosition.calculate(widget.prayerTimes, widget.currentTime);
    final ringColor = AppTheme.legibleAccent(context, AppTheme.primaryAmber);

    return GestureDetector(
      onTap: _openWorldMap,
      child: AnimatedBuilder(
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
                  _SkyDisc(
                    size: widget.size - 12,
                    sun: sun,
                    currentTime: widget.currentTime,
                    weather: widget.weather,
                  ),
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: CircularProgressPainter(
                      progress: widget.progress,
                      color: ringColor,
                    ),
                  ),
                  // Positioned along the sky disc's arc per the sun/moon's
                  // actual current angle, rather than sitting fixed in place -
                  // see _skyArcOffset.
                  Transform.translate(
                    offset: _skyArcOffset(
                      sun.angleDegrees,
                      (widget.size - 12) / 2 * 0.72,
                    ),
                    child: _SkyIcon(
                      sun: sun,
                      weather: widget.weather,
                      currentTime: widget.currentTime,
                      size: widget.size * 0.165,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The countdown ring's sky background - a real equirectangular world map
/// (NASA's public-domain "Blue Marble" composite,
/// assets/images/world_map.jpg) standing in for the whole Earth, scaled to
/// full disc height (so it fills the entire circle - no empty top/bottom
/// caps) and panned left/right over the course of the day to follow the
/// sun/moon icon orbiting it (same arc direction as [_skyArcOffset], reused
/// here horizontally only), so whichever region is "lit" right now stays in
/// view as the apparent current patch of the globe. A fixed day/night
/// gradient (centered on the now-panned, always-centered lit region) and a
/// blue-grey wash under real cloud cover sit on top.
class _SkyDisc extends StatelessWidget {
  final double size;
  final SunPosition sun;
  final DateTime currentTime;
  final WeatherSnapshot? weather;

  const _SkyDisc({
    required this.size,
    required this.sun,
    required this.currentTime,
    required this.weather,
  });

  // Not fully opaque - real day/night Earth maps always leave the night
  // side's geography faintly visible rather than pure black, and it reads
  // as a deliberate "night" tint rather than a hole in the map.
  static const _nightColor = Color(0xCC03060F);

  @override
  Widget build(BuildContext context) {
    // Only the horizontal component of the sun/moon's arc direction is used
    // - [_skyArcOffset]'s vertical component stays confined near the top of
    // the disc all day (by design, so the icon never drops to text height),
    // which isn't meaningful here. -1 (sunrise/dawn) -> 0 (zenith/noon) ->
    // +1 (sunset/dusk), matching the icon's own left-to-right sweep.
    final lightDirX = _skyArcOffset(sun.angleDegrees, 1.0).dx.clamp(-1.0, 1.0);

    // A bright wash at the viewport's center - warm by day (scaled by real
    // sun intensity), cool by night (scaled by real moon illumination) -
    // fading to the (softened) night color toward both edges. Centered
    // rather than following lightDirX a second time: the map pan below
    // already keeps the current light direction centered in view, so the
    // gradient just needs to brighten whatever's now in the middle.
    final Color litTint;
    if (sun.isDaytime) {
      final intensity = sun.intensity.clamp(0.0, 1.0);
      litTint = Color.lerp(
        const Color(0x55FFE9B8),
        const Color(0xCCFFF3D6),
        intensity,
      )!;
    } else {
      final moon = MoonPhase.forDate(currentTime);
      litTint = Color.lerp(
        const Color(0x339FC2EC),
        const Color(0x809FC2EC),
        moon.illumination,
      )!;
    }

    final cloudFraction = weather?.cloudFraction ?? 0.0;
    final cloudAlpha = ((cloudFraction - 0.3) / 0.7).clamp(0.0, 1.0) * 0.45;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The map's native aspect is 2:1; scaling its height to the
            // full circle diameter makes it exactly twice as wide as the
            // circle, so panning it within Align's -1..1 range slides
            // smoothly between showing its left and right halves with no
            // gap ever appearing at any pan position.
            Align(
              alignment: Alignment(lightDirX, 0),
              child: SizedBox(
                width: size * 2,
                height: size,
                child: Image.asset(
                  'assets/images/world_map.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.85,
                  colors: [litTint, _nightColor],
                ),
              ),
            ),
            if (cloudAlpha > 0)
              ColoredBox(color: Colors.blueGrey.withValues(alpha: cloudAlpha)),
          ],
        ),
      ),
    );
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
    final isPartlyCloudy =
        !isOvercast && cloudFraction > _partlyCloudyThreshold;

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
  /// day. This small orb is the actual light source - the globe disc behind
  /// it (see [_SkyDisc]) is lit on whichever side currently faces it.
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
  /// and with a brighter glow than a new or crescent moon. This small orb is
  /// the actual light source - the globe disc behind it (see [_SkyDisc]) is
  /// lit on whichever side currently faces it.
  Widget _buildMoon(bool isOvercast) {
    final moon = MoonPhase.forDate(currentTime);
    final diameter = size * (0.82 + moon.illumination * 0.36);
    final glowAlpha =
        (0.08 + moon.illumination * 0.3) * (isOvercast ? 0.25 : 1.0);

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFFBFC9FF,
            ).withValues(alpha: glowAlpha.clamp(0.0, 1.0)),
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
