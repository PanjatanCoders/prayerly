import 'package:flutter_test/flutter_test.dart';
import 'package:prayerly/utils/sun_position.dart';

Map<String, DateTime> _times(DateTime day) => {
      'Fajr': DateTime(day.year, day.month, day.day, 5, 0),
      'Sunrise': DateTime(day.year, day.month, day.day, 6, 15),
      'Dhuhr': DateTime(day.year, day.month, day.day, 12, 10),
      'Asr': DateTime(day.year, day.month, day.day, 15, 30),
      'Maghrib': DateTime(day.year, day.month, day.day, 18, 20),
      'Isha': DateTime(day.year, day.month, day.day, 19, 40),
    };

void main() {
  final day = DateTime(2026, 3, 15);
  final times = _times(day);

  group('SunPosition', () {
    test('deep night before Fajr', () {
      final sun = SunPosition.calculate(times, DateTime(2026, 3, 15, 2, 0));
      expect(sun.brightness, SkyBrightness.night);
      expect(sun.isDaytime, isFalse);
      expect(sun.intensity, 0.0);
    });

    test('deep night after Isha', () {
      final sun = SunPosition.calculate(times, DateTime(2026, 3, 15, 21, 0));
      expect(sun.brightness, SkyBrightness.night);
    });

    test('dawn twilight between Fajr and Sunrise is dim and rising', () {
      final early = SunPosition.calculate(times, DateTime(2026, 3, 15, 5, 10));
      final late = SunPosition.calculate(times, DateTime(2026, 3, 15, 6, 10));
      expect(early.brightness, SkyBrightness.dim);
      expect(late.brightness, SkyBrightness.dim);
      expect(late.intensity, greaterThan(early.intensity));
    });

    test('peaks bright exactly at Dhuhr (solar noon)', () {
      final sun = SunPosition.calculate(times, times['Dhuhr']!);
      expect(sun.brightness, SkyBrightness.bright);
      expect(sun.intensity, closeTo(1.0, 0.01));
    });

    test('mid-morning is brighter than just after sunrise', () {
      final justAfterSunrise =
          SunPosition.calculate(times, DateTime(2026, 3, 15, 6, 20));
      final midMorning =
          SunPosition.calculate(times, DateTime(2026, 3, 15, 10, 0));
      expect(midMorning.intensity, greaterThan(justAfterSunrise.intensity));
    });

    test('dusk twilight between Maghrib and Isha is dim and falling', () {
      final early = SunPosition.calculate(times, DateTime(2026, 3, 15, 18, 30));
      final late = SunPosition.calculate(times, DateTime(2026, 3, 15, 19, 30));
      expect(early.brightness, SkyBrightness.dim);
      expect(late.brightness, SkyBrightness.dim);
      expect(late.intensity, lessThan(early.intensity));
    });

    test('falls back to medium daylight when prayer times are incomplete', () {
      final sun = SunPosition.calculate({'Fajr': times['Fajr']!}, DateTime.now());
      expect(sun.brightness, SkyBrightness.medium);
      expect(sun.isDaytime, isTrue);
    });
  });

  group('sky arc (angle + sun/moon)', () {
    test('sun rises from just below the horizon during dawn twilight', () {
      final atFajr = SunPosition.calculate(times, times['Fajr']!);
      final atSunrise = SunPosition.calculate(times, times['Sunrise']!);
      expect(atFajr.isSun, isTrue);
      expect(atFajr.angleDegrees, lessThan(0));
      expect(atSunrise.angleDegrees, closeTo(0, 0.5));
    });

    test('sun reaches zenith (90 deg) exactly at Dhuhr', () {
      final sun = SunPosition.calculate(times, times['Dhuhr']!);
      expect(sun.isSun, isTrue);
      expect(sun.angleDegrees, closeTo(90, 0.5));
    });

    test('sun approaches 180 deg just before Maghrib', () {
      final sun = SunPosition.calculate(
        times,
        times['Maghrib']!.subtract(const Duration(seconds: 1)),
      );
      expect(sun.isSun, isTrue);
      expect(sun.angleDegrees, closeTo(180, 0.5));
    });

    test('moon takes over the instant Maghrib passes', () {
      final justAfterMaghrib =
          SunPosition.calculate(times, times['Maghrib']!.add(const Duration(minutes: 1)));
      expect(justAfterMaghrib.isSun, isFalse);
      expect(justAfterMaghrib.angleDegrees, greaterThan(0));
      expect(justAfterMaghrib.angleDegrees, lessThan(90));
    });

    test('moon angle increases monotonically overnight', () {
      double angleAt(int hour) => SunPosition.calculate(
            times,
            DateTime(2026, 3, 16, hour),
          ).angleDegrees;

      expect(angleAt(1), lessThan(angleAt(3)));
      final beforeFajr = SunPosition.calculate(times, DateTime(2026, 3, 16, 4, 30));
      expect(beforeFajr.isSun, isFalse);
      expect(beforeFajr.angleDegrees, greaterThan(90));
    });
  });
}
