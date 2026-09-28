import 'package:flutter_test/flutter_test.dart';
import 'package:prayerly/services/prayer_service.dart';

/// A plausible day of prayer times, used to exercise the status logic without
/// depending on the astronomy.
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

  group('current prayer status', () {
    test('mid-morning sits between Sunrise and Dhuhr', () {
      final status = PrayerService.getCurrentPrayerStatus(
        times,
        DateTime(2026, 3, 15, 9, 0),
      );

      expect(status.currentPrayer, 'Sunrise');
      expect(status.nextPrayer, 'Dhuhr');
      expect(status.timeRemaining, const Duration(hours: 3, minutes: 10));
      expect(status.progress, greaterThan(0));
      expect(status.progress, lessThan(1));
    });

    test('just after Fajr sits between Fajr and Sunrise', () {
      final status = PrayerService.getCurrentPrayerStatus(
        times,
        DateTime(2026, 3, 15, 5, 30),
      );

      expect(status.currentPrayer, 'Fajr');
      expect(status.nextPrayer, 'Sunrise');
    });

    test('just after sunrise switches away from Fajr', () {
      // Regression: the status used to skip Sunrise entirely, so the app
      // kept showing "Fajr" as the active prayer well past sunrise.
      final status = PrayerService.getCurrentPrayerStatus(
        times,
        DateTime(2026, 3, 15, 6, 30),
      );

      expect(status.currentPrayer, 'Sunrise');
      expect(status.nextPrayer, 'Dhuhr');
    });

    test('after Isha the next prayer is tomorrow Fajr', () {
      final status = PrayerService.getCurrentPrayerStatus(
        times,
        DateTime(2026, 3, 15, 21, 0),
      );

      expect(status.currentPrayer, 'Isha');
      expect(status.nextPrayer, 'Fajr');
      expect(status.timeRemaining, const Duration(hours: 8));
      expect(status.progress, greaterThan(0));
    });

    test('after midnight the progress ring keeps advancing', () {
      // Regression: anchoring on today's (still future) Isha pinned progress
      // to zero for the whole stretch between midnight and Fajr.
      final status = PrayerService.getCurrentPrayerStatus(
        times,
        DateTime(2026, 3, 16, 3, 0),
      );

      expect(status.currentPrayer, 'Isha');
      expect(status.nextPrayer, 'Fajr');
      expect(status.progress, greaterThan(0.0));
      expect(status.progress, lessThan(1.0));
    });

    test('progress increases monotonically through the night', () {
      double progressAt(int hour) => PrayerService.getCurrentPrayerStatus(
            times,
            DateTime(2026, 3, 16, hour),
          ).progress;

      expect(progressAt(1), lessThan(progressAt(2)));
      expect(progressAt(2), lessThan(progressAt(4)));
    });
  });

  group('local calculation', () {
    test('produces ordered times for Dhaka', () async {
      final data = await PrayerService.getPrayerTimes(
        latitude: 23.8103,
        longitude: 90.4125,
        date: day,
      );

      const order = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
      for (var i = 1; i < order.length; i++) {
        expect(
          data.prayerTimes[order[i]]!.isAfter(data.prayerTimes[order[i - 1]]!),
          isTrue,
          reason: '${order[i]} should follow ${order[i - 1]}',
        );
      }
    });

    test('reports a Hijri date', () async {
      final data = await PrayerService.getPrayerTimes(
        latitude: 23.8103,
        longitude: 90.4125,
        date: day,
      );

      expect(data.islamicDate, isNotEmpty);
      expect(data.islamicDate, contains('14'));
    });
  });
}
