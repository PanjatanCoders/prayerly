import 'dart:math';

/// How bright the sky currently is, in three daylight tiers plus night.
enum SkyBrightness { night, dim, medium, bright }

/// Where the sun (or moon) sits right now, derived purely from today's
/// prayer times - no separate astronomy call needed, since Dhuhr is already
/// solar noon and Sunrise/Maghrib already mark sunrise/sunset for this
/// location and date.
///
/// [intensity] is a continuous 0..1 value that peaks at Dhuhr and falls to 0
/// at Sunrise/Maghrib, with a soft twilight ramp either side of the Fajr and
/// Isha boundaries. [brightness] buckets that value into the three daylight
/// tiers the UI asks for (dim / medium / bright), or [SkyBrightness.night]
/// outside the Fajr-Isha window entirely.
class SunPosition {
  final SkyBrightness brightness;
  final double intensity;
  final bool isDaytime;

  const SunPosition({
    required this.brightness,
    required this.intensity,
    required this.isDaytime,
  });

  factory SunPosition.calculate(
    Map<String, DateTime> prayerTimes,
    DateTime now,
  ) {
    final fajr = prayerTimes['Fajr'];
    final sunrise = prayerTimes['Sunrise'];
    final dhuhr = prayerTimes['Dhuhr'];
    final maghrib = prayerTimes['Maghrib'];
    final isha = prayerTimes['Isha'];

    if (fajr == null ||
        sunrise == null ||
        dhuhr == null ||
        maghrib == null ||
        isha == null) {
      return const SunPosition(
        brightness: SkyBrightness.medium,
        intensity: 0.5,
        isDaytime: true,
      );
    }

    // Night: before Fajr (pre-dawn) or at/after Isha.
    if (now.isBefore(fajr) || !now.isBefore(isha)) {
      return const SunPosition(
        brightness: SkyBrightness.night,
        intensity: 0.0,
        isDaytime: false,
      );
    }

    // Dawn twilight: Fajr -> Sunrise, brightness ramps 0 -> ~0.3.
    if (now.isBefore(sunrise)) {
      final t = _fraction(fajr, sunrise, now);
      return SunPosition(
        brightness: SkyBrightness.dim,
        intensity: 0.3 * t,
        isDaytime: true,
      );
    }

    // Dusk twilight: Maghrib -> Isha, brightness ramps ~0.3 -> 0.
    if (!now.isBefore(maghrib)) {
      final t = _fraction(maghrib, isha, now);
      return SunPosition(
        brightness: SkyBrightness.dim,
        intensity: 0.3 * (1 - t),
        isDaytime: true,
      );
    }

    // Full daylight: Sunrise -> Dhuhr -> Maghrib, a smooth curve that peaks
    // exactly at Dhuhr (solar noon) rather than the geometric midpoint of
    // sunrise/sunset, since Dhuhr is where the sun actually culminates.
    final double intensity;
    if (now.isBefore(dhuhr)) {
      intensity = sin(_fraction(sunrise, dhuhr, now) * pi / 2);
    } else {
      intensity = cos(_fraction(dhuhr, maghrib, now) * pi / 2);
    }

    final brightness = intensity > 0.75
        ? SkyBrightness.bright
        : intensity > 0.35
            ? SkyBrightness.medium
            : SkyBrightness.dim;

    return SunPosition(
      brightness: brightness,
      intensity: intensity.clamp(0.0, 1.0),
      isDaytime: true,
    );
  }

  static double _fraction(DateTime from, DateTime to, DateTime now) {
    final total = to.difference(from).inSeconds;
    if (total <= 0) return 0;
    final elapsed = now.difference(from).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}
