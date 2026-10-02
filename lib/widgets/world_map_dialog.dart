import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/location_data.dart';
import '../services/prayer_service.dart';
import '../services/weather_service.dart';
import '../utils/moon_phase.dart';
import '../utils/sun_position.dart';
import '../utils/theme/app_theme.dart';

/// Opens a larger, unpanned view of the same world map the countdown
/// ring's small globe uses - the whole map at once (not cropped/panned to
/// fit a circle) plus a few live numbers, for whoever taps the ring wanting
/// more than the small icon can show.
Future<void> showWorldMapDialog(
  BuildContext context, {
  required LocationData? locationData,
  required Map<String, DateTime> prayerTimes,
  required DateTime currentTime,
  required WeatherSnapshot? weather,
}) {
  return showDialog(
    context: context,
    builder: (context) => _WorldMapDialog(
      locationData: locationData,
      prayerTimes: prayerTimes,
      currentTime: currentTime,
      weather: weather,
    ),
  );
}

/// Same left(-1)-to-right(+1) convention [_skyArcOffset] in
/// circular_timer_widget.dart uses for the sun/moon icon's sweep - 0 deg
/// (sunrise) -> -1, 90 deg (zenith) -> 0, 180 deg (sunset) -> +1. Kept as
/// its own tiny copy here rather than importing that file's private
/// function; not worth exporting a one-line formula across files for.
double _lightDirectionX(double angleDegrees) {
  final rad = angleDegrees.clamp(0.0, 180.0) * math.pi / 180.0;
  return (-math.cos(rad)).clamp(-1.0, 1.0);
}

class _WorldMapDialog extends StatelessWidget {
  final LocationData? locationData;
  final Map<String, DateTime> prayerTimes;
  final DateTime currentTime;
  final WeatherSnapshot? weather;

  const _WorldMapDialog({
    required this.locationData,
    required this.prayerTimes,
    required this.currentTime,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final sun = SunPosition.calculate(prayerTimes, currentTime);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final accent = AppTheme.legibleAccent(context, AppTheme.primaryAmber);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        // The header (with its close button) stays fixed; the map + status
        // rows below it scroll - on a short screen, or with a long weather
        // description, the combination can run taller than the available
        // dialog height, and a plain Column would overflow instead.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.public, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'World Light Map',
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 2,
                        child: _FullWorldMap(
                          sun: sun,
                          currentTime: currentTime,
                          locationData: locationData,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _StatusRows(sun: sun, currentTime: currentTime, weather: weather),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The full, un-cropped 2:1 map (unlike the small ring's panned/cropped
/// circle) with the same day/night tint logic, plus a pin at the user's
/// own location when known.
class _FullWorldMap extends StatelessWidget {
  final SunPosition sun;
  final DateTime currentTime;
  final LocationData? locationData;

  const _FullWorldMap({
    required this.sun,
    required this.currentTime,
    required this.locationData,
  });

  static const _nightColor = Color(0xCC03060F);

  @override
  Widget build(BuildContext context) {
    final lightDirX = _lightDirectionX(sun.angleDegrees);

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

    final location = locationData;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/world_map.jpg', fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(lightDirX, 0),
              radius: 0.9,
              colors: [litTint, _nightColor],
            ),
          ),
        ),
        if (location != null)
          Align(
            alignment: Alignment(
              (location.longitude / 180).clamp(-1.0, 1.0),
              (-location.latitude / 90).clamp(-1.0, 1.0),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.redAccent,
              size: 22,
              shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
            ),
          ),
      ],
    );
  }
}

class _StatusRows extends StatelessWidget {
  final SunPosition sun;
  final DateTime currentTime;
  final WeatherSnapshot? weather;

  const _StatusRows({
    required this.sun,
    required this.currentTime,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final progressPercent = (sun.angleDegrees.clamp(0.0, 180.0) / 180 * 100)
        .round();

    final rows = <(IconData, String, String)>[
      (Icons.schedule, 'Local time', PrayerService.formatTime(currentTime)),
      if (sun.isDaytime)
        (
          Icons.wb_sunny,
          'Sun intensity',
          '${(sun.intensity.clamp(0.0, 1.0) * 100).round()}%',
        )
      else
        (
          Icons.nightlight_round,
          'Moon illumination',
          '${(MoonPhase.forDate(currentTime).illumination * 100).round()}% '
              '(${MoonPhase.forDate(currentTime).isWaxing ? "waxing" : "waning"})',
        ),
      (
        Icons.explore,
        sun.isDaytime ? 'Day progress' : 'Night progress',
        '$progressPercent%',
      ),
      if (weather != null)
        (
          Icons.thermostat,
          'Weather here',
          '${weather!.temperatureCelsius.round()}°C · ${weather!.description}',
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows
          .map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    row.$1,
                    size: 16,
                    color: onSurface.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    row.$2,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    row.$3,
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
