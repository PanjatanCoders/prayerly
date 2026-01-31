// services/prayer_service.dart
// Fully offline prayer time calculation - no API calls required
// ignore_for_file: avoid_print

import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrayerService {
  static const String _cacheKey = 'cached_prayer_times';
  static const String _cacheDateKey = 'cached_prayer_date';
  static const String _cacheLocationKey = 'cached_prayer_location';

  // Use Hanafi method by default
  static const bool _useHanafiMethod = true;

  // Calculation method angles
  static const double _fajrAngle = 18.0;  // Karachi method
  static const double _ishaAngle = 18.0;  // Karachi method

  /// Get prayer times for given coordinates - FULLY OFFLINE
  static Future<PrayerTimesData> getPrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();

    // Check cache first
    final cachedData = await _getCachedPrayerTimes(latitude, longitude, targetDate);
    if (cachedData != null) {
      return cachedData;
    }

    // Calculate locally - no API calls
    final prayerTimesData = _calculatePrayerTimesLocally(
      latitude: latitude,
      longitude: longitude,
      date: targetDate,
    );

    // Cache the results
    await _cachePrayerTimes(prayerTimesData, latitude, longitude, targetDate);

    return prayerTimesData;
  }

  /// Get cached prayer times if valid
  static Future<PrayerTimesData?> _getCachedPrayerTimes(
    double latitude,
    double longitude,
    DateTime date,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDate = prefs.getString(_cacheDateKey);
      final cachedLocation = prefs.getString(_cacheLocationKey);
      final cachedTimes = prefs.getString(_cacheKey);

      if (cachedDate == null || cachedTimes == null || cachedLocation == null) {
        return null;
      }

      // Check if same day
      final dateStr = '${date.year}-${date.month}-${date.day}';
      if (cachedDate != dateStr) {
        return null;
      }

      // Check if location is close enough (within ~1km)
      final locationParts = cachedLocation.split(',');
      final cachedLat = double.parse(locationParts[0]);
      final cachedLng = double.parse(locationParts[1]);

      if ((latitude - cachedLat).abs() > 0.01 || (longitude - cachedLng).abs() > 0.01) {
        return null;
      }

      // Parse cached times
      final timesMap = json.decode(cachedTimes) as Map<String, dynamic>;
      final prayerTimes = <String, DateTime>{};

      timesMap.forEach((key, value) {
        if (key != 'islamicDate') {
          prayerTimes[key] = DateTime.parse(value);
        }
      });

      return PrayerTimesData(
        prayerTimes: prayerTimes,
        islamicDate: timesMap['islamicDate'] ?? _calculateIslamicDate(date),
        isDefault: false,
      );
    } catch (e) {
      return null;
    }
  }

  /// Cache prayer times
  static Future<void> _cachePrayerTimes(
    PrayerTimesData data,
    double latitude,
    double longitude,
    DateTime date,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final timesMap = <String, String>{};
      data.prayerTimes.forEach((key, value) {
        timesMap[key] = value.toIso8601String();
      });
      timesMap['islamicDate'] = data.islamicDate;

      await prefs.setString(_cacheKey, json.encode(timesMap));
      await prefs.setString(_cacheDateKey, '${date.year}-${date.month}-${date.day}');
      await prefs.setString(_cacheLocationKey, '$latitude,$longitude');
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Calculate prayer times locally - NO INTERNET REQUIRED
  static PrayerTimesData _calculatePrayerTimesLocally({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    final Map<String, DateTime> prayerTimes = {};

    try {
      // Convert to radians
      final double latRad = latitude * (pi / 180);

      // Day of year
      final int dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;

      // Solar declination (more accurate formula)
      final double declination = _calculateDeclination(dayOfYear);

      // Equation of time
      final double eqTime = _calculateEquationOfTime(dayOfYear);

      // Time zone offset
      final double tzOffset = date.timeZoneOffset.inMinutes / 60.0;

      // Solar noon (in hours, local time)
      final double solarNoon = 12 + tzOffset - (longitude / 15) - (eqTime / 60);

      // Fajr
      prayerTimes['Fajr'] = _calculatePrayerTime(
        latRad, declination, solarNoon, -_fajrAngle, true, date,
      );

      // Sunrise
      prayerTimes['Sunrise'] = _calculatePrayerTime(
        latRad, declination, solarNoon, -0.833, true, date,
      );

      // Dhuhr (solar noon + safety margin)
      final int noonHours = solarNoon.floor();
      final int noonMinutes = ((solarNoon - noonHours) * 60).round() + 2;
      prayerTimes['Dhuhr'] = DateTime(date.year, date.month, date.day, noonHours, noonMinutes);

      // Asr (Hanafi method: shadow = 2x object + noon shadow)
      prayerTimes['Asr'] = _calculateAsr(
        latitude: latitude,
        declination: declination,
        solarNoon: solarNoon,
        date: date,
        hanafi: _useHanafiMethod,
      );

      // Maghrib (sunset)
      prayerTimes['Maghrib'] = _calculatePrayerTime(
        latRad, declination, solarNoon, -0.833, false, date,
      );

      // Isha
      prayerTimes['Isha'] = _calculatePrayerTime(
        latRad, declination, solarNoon, -_ishaAngle, false, date,
      );

      // Validate times
      _validateAndFixTimes(prayerTimes, date);

    } catch (e) {
      print('Error in local calculation: $e');
      // Fallback times
      prayerTimes['Fajr'] = DateTime(date.year, date.month, date.day, 5, 0);
      prayerTimes['Sunrise'] = DateTime(date.year, date.month, date.day, 6, 30);
      prayerTimes['Dhuhr'] = DateTime(date.year, date.month, date.day, 12, 30);
      prayerTimes['Asr'] = DateTime(date.year, date.month, date.day, 15, 45);
      prayerTimes['Maghrib'] = DateTime(date.year, date.month, date.day, 18, 30);
      prayerTimes['Isha'] = DateTime(date.year, date.month, date.day, 20, 0);
    }

    return PrayerTimesData(
      prayerTimes: prayerTimes,
      islamicDate: _calculateIslamicDate(date),
      isDefault: false,
    );
  }

  /// Calculate solar declination
  static double _calculateDeclination(int dayOfYear) {
    final double angle = (360 / 365.0) * (dayOfYear - 81);
    return 23.45 * sin(angle * (pi / 180)) * (pi / 180);
  }

  /// Calculate equation of time
  static double _calculateEquationOfTime(int dayOfYear) {
    final double b = (360 / 365.0) * (dayOfYear - 81) * (pi / 180);
    return 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b);
  }

  /// Calculate Asr time
  static DateTime _calculateAsr({
    required double latitude,
    required double declination,
    required double solarNoon,
    required DateTime date,
    required bool hanafi,
  }) {
    try {
      final double latRad = latitude * (pi / 180);

      // Shadow factor: 1 for Shafi, 2 for Hanafi
      final double shadowFactor = hanafi ? 2.0 : 1.0;

      // Calculate noon altitude
      final double noonAltitude = asin(
        sin(declination) * sin(latRad) + cos(declination) * cos(latRad)
      );

      // Asr angle
      final double cotNoonAlt = cos(noonAltitude) / sin(noonAltitude);
      final double asrAltitude = atan(1 / (shadowFactor + cotNoonAlt));

      // Hour angle
      final double cosHourAngle = (sin(asrAltitude) - sin(latRad) * sin(declination)) /
          (cos(latRad) * cos(declination));

      if (cosHourAngle.abs() > 1) {
        // Asr doesn't occur, use default
        return DateTime(date.year, date.month, date.day, 15, 30);
      }

      final double hourAngle = acos(cosHourAngle) * (180 / pi);
      final double asrTime = solarNoon + hourAngle / 15;

      final int hours = asrTime.floor();
      final int minutes = ((asrTime - hours) * 60).round();

      return DateTime(date.year, date.month, date.day, hours.clamp(0, 23), minutes.clamp(0, 59));
    } catch (e) {
      return DateTime(date.year, date.month, date.day, 15, 30);
    }
  }

  /// Helper method for prayer time calculation
  static DateTime _calculatePrayerTime(
    double latRad,
    double declination,
    double solarNoon,
    double angle,
    bool isBefore,
    DateTime date
  ) {
    try {
      final double cosHourAngle = (sin(angle * (pi / 180)) - sin(latRad) * sin(declination)) /
          (cos(latRad) * cos(declination));

      if (cosHourAngle.abs() > 1) {
        // Sun doesn't reach this angle
        return DateTime(date.year, date.month, date.day, 12, 0);
      }

      final double hourAngle = acos(cosHourAngle) * (180 / pi);

      final double prayerTime = isBefore
        ? solarNoon - hourAngle / 15
        : solarNoon + hourAngle / 15;

      final int hours = prayerTime.floor();
      final int minutes = ((prayerTime - hours) * 60).round();

      return DateTime(date.year, date.month, date.day, hours.clamp(0, 23), minutes.clamp(0, 59));
    } catch (e) {
      return DateTime(date.year, date.month, date.day, 12, 0);
    }
  }

  /// Validate and fix prayer times order
  static void _validateAndFixTimes(Map<String, DateTime> times, DateTime date) {
    final order = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (int i = 1; i < order.length; i++) {
      final prev = times[order[i - 1]]!;
      final curr = times[order[i]]!;

      if (curr.isBefore(prev) || curr.isAtSameMomentAs(prev)) {
        // Add minimum gap
        times[order[i]] = prev.add(const Duration(minutes: 30));
      }
    }
  }

  /// Calculate Islamic (Hijri) date - OFFLINE
  static String _calculateIslamicDate(DateTime date) {
    // Umm al-Qura calendar approximation
    // Reference: 1 Muharram 1 AH = July 16, 622 CE (Julian)

    final int jd = _gregorianToJulianDay(date);
    final hijri = _julianDayToHijri(jd);

    final months = [
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Shaban',
      'Ramadan', 'Shawwal', 'Dhul Qadah', 'Dhul Hijjah'
    ];

    final monthName = months[(hijri['month']! - 1).clamp(0, 11)];
    return '${hijri['day']} $monthName ${hijri['year']}';
  }

  /// Convert Gregorian date to Julian Day number
  static int _gregorianToJulianDay(DateTime date) {
    int y = date.year;
    int m = date.month;
    int d = date.day;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();

    return (365.25 * (y + 4716)).floor() +
           (30.6001 * (m + 1)).floor() +
           d + b - 1524;
  }

  /// Convert Julian Day to Hijri date
  static Map<String, int> _julianDayToHijri(int jd) {
    // Kuwaiti algorithm
    int l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j = ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
            (l / 5670).floor() * ((43 * l) / 15238).floor();
    l = l - ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() + 29;
    int m = ((24 * l) / 709).floor();
    int d = l - ((709 * m) / 24).floor();
    int y = 30 * n + j - 30;

    return {'year': y, 'month': m, 'day': d};
  }

  /// Format time for display
  static String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Get current prayer status
  static PrayerStatus getCurrentPrayerStatus(
    Map<String, DateTime> prayerTimes,
    DateTime currentTime,
  ) {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (int i = 0; i < prayers.length; i++) {
      final prayerTime = prayerTimes[prayers[i]]!;

      if (currentTime.isBefore(prayerTime)) {
        final timeRemaining = prayerTime.difference(currentTime);
        final previousPrayer = i == 0 ? prayers.last : prayers[i - 1];

        return PrayerStatus(
          currentPrayer: previousPrayer,
          nextPrayer: prayers[i],
          timeRemaining: timeRemaining,
          progress: _calculateProgress(prayerTimes, previousPrayer, prayers[i], currentTime),
        );
      }
    }

    // After Isha, next is Fajr
    final timeToFajr = prayerTimes['Fajr']!.add(const Duration(days: 1)).difference(currentTime);

    return PrayerStatus(
      currentPrayer: 'Isha',
      nextPrayer: 'Fajr',
      timeRemaining: timeToFajr,
      progress: _calculateProgress(prayerTimes, 'Isha', 'Fajr', currentTime),
    );
  }

  /// Calculate progress between prayers
  static double _calculateProgress(
    Map<String, DateTime> prayerTimes,
    String currentPrayer,
    String nextPrayer,
    DateTime currentTime,
  ) {
    final currentPrayerTime = prayerTimes[currentPrayer]!;
    final nextPrayerTime = nextPrayer == 'Fajr' && currentPrayer == 'Isha'
        ? prayerTimes[nextPrayer]!.add(const Duration(days: 1))
        : prayerTimes[nextPrayer]!;

    final totalDuration = nextPrayerTime.difference(currentPrayerTime);
    final elapsed = currentTime.difference(currentPrayerTime);

    if (totalDuration.inSeconds <= 0) return 0.0;

    final progress = elapsed.inSeconds / totalDuration.inSeconds;
    return progress.clamp(0.0, 1.0);
  }

  static String formatCurrentTime(DateTime currentTime) {
    final hour = currentTime.hour;
    final minute = currentTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

/// Data models
class PrayerTimesData {
  final Map<String, DateTime> prayerTimes;
  final String islamicDate;
  final bool isDefault;

  PrayerTimesData({
    required this.prayerTimes,
    required this.islamicDate,
    required this.isDefault,
  });
}

class PrayerStatus {
  final String currentPrayer;
  final String nextPrayer;
  final Duration timeRemaining;
  final double progress;

  PrayerStatus({
    required this.currentPrayer,
    required this.nextPrayer,
    required this.timeRemaining,
    required this.progress,
  });
}
