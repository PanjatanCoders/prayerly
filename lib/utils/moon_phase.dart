import 'dart:math';

/// The moon's current phase, computed purely from the date - no network or
/// device sensor needed, same "everything on-device" philosophy as
/// [SunPosition] (see sun_position.dart).
///
/// Uses the synodic month (new moon to new moon, ~29.53 days) against a
/// known reference new moon (2000-01-06 18:14 UTC) to get the moon's age in
/// the current cycle, which is enough to derive how much of its face is lit
/// and which side the light is on - real lunar apps use the same base
/// calculation, just with extra precision this app doesn't need.
class MoonPhase {
  /// Days into the current synodic month, 0 (new moon) to ~29.53.
  final double ageDays;

  /// Fraction of the cycle elapsed, 0 (new) to 1 (next new); 0.5 is full.
  final double cycleFraction;

  /// Fraction of the moon's face that is lit, 0 (new) to 1 (full).
  final double illumination;

  /// True from new moon to full moon (the lit side is growing).
  final bool isWaxing;

  /// Human-readable phase name for display.
  final String name;

  const MoonPhase({
    required this.ageDays,
    required this.cycleFraction,
    required this.illumination,
    required this.isWaxing,
    required this.name,
  });

  static const double _synodicMonthDays = 29.530588853;
  static final DateTime _referenceNewMoonUtc = DateTime.utc(2000, 1, 6, 18, 14);

  factory MoonPhase.forDate(DateTime date) {
    final daysSinceReference =
        date.toUtc().difference(_referenceNewMoonUtc).inMinutes / (60 * 24);

    var age = daysSinceReference % _synodicMonthDays;
    if (age < 0) age += _synodicMonthDays;

    final fraction = age / _synodicMonthDays;
    final illumination = (1 - cos(2 * pi * fraction)) / 2;

    return MoonPhase(
      ageDays: age,
      cycleFraction: fraction,
      illumination: illumination,
      isWaxing: fraction < 0.5,
      name: _nameFor(fraction),
    );
  }

  static String _nameFor(double fraction) {
    if (fraction < 0.03 || fraction > 0.97) return 'New Moon';
    if (fraction < 0.22) return 'Waxing Crescent';
    if (fraction < 0.28) return 'First Quarter';
    if (fraction < 0.47) return 'Waxing Gibbous';
    if (fraction < 0.53) return 'Full Moon';
    if (fraction < 0.72) return 'Waning Gibbous';
    if (fraction < 0.78) return 'Last Quarter';
    return 'Waning Crescent';
  }
}
