import 'dart:math';

/// The sun's true position in the sky - real astronomy, independent of the
/// display-only [SunPosition] gauge in `sun_position.dart` (which places the
/// sun/moon marker along a purely cosmetic arc derived from today's prayer
/// times, not from real coordinates).
///
/// [altitudeDegrees] is the sun's actual elevation above the horizon: 0 at
/// the horizon, 90 straight up, negative while the sun is below the horizon.
/// A negative reading at night is still a legitimate angle - it's the same
/// kind of solar depression angle this app already uses for the Fajr/Isha
/// twilight angles in `PrayerService`.
///
/// [azimuthDegrees] is the compass bearing to the sun, measured clockwise
/// from true north (0 = N, 90 = E, 180 = S, 270 = W).
class SolarAngle {
  final double altitudeDegrees;
  final double azimuthDegrees;

  const SolarAngle({
    required this.altitudeDegrees,
    required this.azimuthDegrees,
  });

  /// Uses the same declination/equation-of-time approximations as
  /// `PrayerService._calculateDeclination`/`_calculateEquationOfTime`, so the
  /// sun's displayed position agrees with the angles this app already
  /// derives prayer times from.
  factory SolarAngle.calculate({
    required double latitude,
    required double longitude,
    required DateTime time,
  }) {
    final latRad = latitude * pi / 180;
    final dayOfYear = time.difference(DateTime(time.year, 1, 1)).inDays + 1;

    final declAngleDeg = (360 / 365.0) * (dayOfYear - 81);
    final declRad = 23.45 * sin(declAngleDeg * pi / 180) * pi / 180;

    final b = (360 / 365.0) * (dayOfYear - 81) * pi / 180;
    final eqTimeMinutes = 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b);

    final tzOffsetHours = time.timeZoneOffset.inMinutes / 60.0;
    final solarNoonHours =
        12 + tzOffsetHours - (longitude / 15) - (eqTimeMinutes / 60);

    final localHours = time.hour + time.minute / 60.0 + time.second / 3600.0;
    final hourAngleDeg = 15 * (localHours - solarNoonHours);
    final hourAngleRad = hourAngleDeg * pi / 180;

    final altitudeRad = asin(
      sin(latRad) * sin(declRad) +
          cos(latRad) * cos(declRad) * cos(hourAngleRad),
    );

    final cosAltitude = cos(altitudeRad);
    double azimuthDeg;
    if (cosAltitude.abs() < 1e-6) {
      // Directly overhead or underfoot: azimuth is undefined:
      azimuthDeg = 0;
    } else {
      final cosAzimuth =
          ((sin(declRad) - sin(altitudeRad) * sin(latRad)) /
                  (cosAltitude * cos(latRad)))
              .clamp(-1.0, 1.0);
      final azimuthRad = acos(cosAzimuth);
      azimuthDeg = hourAngleDeg > 0
          ? 360 - azimuthRad * 180 / pi
          : azimuthRad * 180 / pi;
    }

    return SolarAngle(
      altitudeDegrees: altitudeRad * 180 / pi,
      azimuthDegrees: azimuthDeg,
    );
  }

  static const _compassPoints = [
    'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW',
  ];

  /// 8-point compass abbreviation for [azimuthDegrees].
  String get compassDirection {
    final index = ((azimuthDegrees % 360) / 45).round() % 8;
    return _compassPoints[index];
  }
}
