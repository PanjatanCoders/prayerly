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
///
/// [isSun] and [angleDegrees] describe where to actually draw the body along
/// a sky arc: 0 deg is rising at the horizon, 90 deg is the zenith (directly
/// overhead - Dhuhr for the sun, local "midnight" for the moon), 180 deg is
/// setting at the opposite horizon. The sun's angle can dip slightly below 0
/// during the Fajr-Sunrise dawn twilight, when it's crept toward the horizon
/// but hasn't risen yet.
class SunPosition {
  final SkyBrightness brightness;
  final double intensity;
  final bool isDaytime;
  final bool isSun;
  final double angleDegrees;

  const SunPosition({
    required this.brightness,
    required this.intensity,
    required this.isDaytime,
    required this.isSun,
    required this.angleDegrees,
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
        isSun: true,
        angleDegrees: 90,
      );
    }

    final brightnessResult = _brightnessAt(fajr, sunrise, dhuhr, maghrib, isha, now);
    final arc = _arcAt(fajr, sunrise, dhuhr, maghrib, now);

    return SunPosition(
      brightness: brightnessResult.$1,
      intensity: brightnessResult.$2,
      isDaytime: brightnessResult.$3,
      isSun: arc.$1,
      angleDegrees: arc.$2,
    );
  }

  static (SkyBrightness, double, bool) _brightnessAt(
    DateTime fajr,
    DateTime sunrise,
    DateTime dhuhr,
    DateTime maghrib,
    DateTime isha,
    DateTime now,
  ) {
    // Night: before Fajr (pre-dawn) or at/after Isha.
    if (now.isBefore(fajr) || !now.isBefore(isha)) {
      return (SkyBrightness.night, 0.0, false);
    }

    // Dawn twilight: Fajr -> Sunrise, brightness ramps 0 -> ~0.3.
    if (now.isBefore(sunrise)) {
      final t = _fraction(fajr, sunrise, now);
      return (SkyBrightness.dim, 0.3 * t, true);
    }

    // Dusk twilight: Maghrib -> Isha, brightness ramps ~0.3 -> 0.
    if (!now.isBefore(maghrib)) {
      final t = _fraction(maghrib, isha, now);
      return (SkyBrightness.dim, 0.3 * (1 - t), true);
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

    return (brightness, intensity.clamp(0.0, 1.0), true);
  }

  /// The sun owns the sky from Fajr (creeping up to the horizon) through
  /// Maghrib; the moon owns it from Maghrib through Fajr, arcing across
  /// whichever night - tonight's or the tail of last night's - [now] falls
  /// in. Both arcs are anchored so the zenith (90 deg) lands on the body's
  /// real high point: Dhuhr for the sun, the Maghrib-Fajr midpoint for the
  /// moon (the same "middle of the night" some fiqh calculations use for
  /// Isha's end).
  static (bool, double) _arcAt(
    DateTime fajr,
    DateTime sunrise,
    DateTime dhuhr,
    DateTime maghrib,
    DateTime now,
  ) {
    if (now.isBefore(fajr)) {
      // Tail of last night: anchor the moon's arc on yesterday's Maghrib.
      final prevMaghrib = maghrib.subtract(const Duration(days: 1));
      return (false, _moonAngle(prevMaghrib, fajr, now));
    }

    if (now.isBefore(sunrise)) {
      // Dawn twilight: the sun is below the horizon but rising towards it.
      final t = _fraction(fajr, sunrise, now);
      return (true, -15 + 15 * t);
    }

    if (now.isBefore(maghrib)) {
      if (now.isBefore(dhuhr)) {
        return (true, 90 * _fraction(sunrise, dhuhr, now));
      }
      return (true, 90 + 90 * _fraction(dhuhr, maghrib, now));
    }

    // Tonight: anchor the moon's arc on tomorrow's Fajr (approximated as
    // today's Fajr time, which barely drifts day to day).
    final nextFajr = fajr.add(const Duration(days: 1));
    return (false, _moonAngle(maghrib, nextFajr, now));
  }

  static double _moonAngle(DateTime riseAnchor, DateTime setAnchor, DateTime now) {
    final mid = riseAnchor.add(setAnchor.difference(riseAnchor) ~/ 2);
    if (now.isBefore(mid)) {
      return 90 * _fraction(riseAnchor, mid, now);
    }
    return 90 + 90 * _fraction(mid, setAnchor, now);
  }

  static double _fraction(DateTime from, DateTime to, DateTime now) {
    final total = to.difference(from).inSeconds;
    if (total <= 0) return 0;
    final elapsed = now.difference(from).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}
