// services/prayer_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PrayerService {
  // University of Islamic Sciences, Karachi method = 1
  static const int _calculationMethod = 1;
  static const String _baseUrl = 'http://api.aladhan.com/v1/timings';

  /// Fetches prayer times for given coordinates and date
  static Future<PrayerTimesData> getPrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateString = DateFormat('dd-MM-yyyy').format(targetDate);

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/$dateString?latitude=$latitude&longitude=$longitude&method=$_calculationMethod'
        ),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parsePrayerTimesResponse(data, targetDate);
      } else {
        print('API Error: ${response.statusCode}');
        return _getDefaultPrayerTimes(targetDate);
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      return _getDefaultPrayerTimes(date ?? DateTime.now());
    }
  }

  /// Parses the API response and returns prayer times data
  static PrayerTimesData _parsePrayerTimesResponse(Map<String, dynamic> data, DateTime date) {
    try {
      final timings = data['data']['timings'];
      final hijriDate = data['data']['date']['hijri'];

      final prayerTimes = {
        'Fajr': _parseTimeString(timings['Fajr'], date),
        'Sunrise': _parseTimeString(timings['Sunrise'], date),
        'Dhuhr': _parseTimeString(timings['Dhuhr'], date),
        'Asr': _parseTimeString(timings['Asr'], date),
        'Maghrib': _parseTimeString(timings['Maghrib'], date),
        'Isha': _parseTimeString(timings['Isha'], date),
      };

      final islamicDate = "${hijriDate['day']} ${hijriDate['month']['en']}, ${hijriDate['year']}";

      return PrayerTimesData(
        prayerTimes: prayerTimes,
        islamicDate: islamicDate,
        gregorianDate: date,
        isDefault: false,
      );
    } catch (e) {
      print('Error parsing prayer times response: $e');
      return _getDefaultPrayerTimes(date);
    }
  }

  /// Parses time string and creates DateTime object
  static DateTime _parseTimeString(String timeString, DateTime date) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      print('Error parsing time string: $timeString');
      // Return a default time if parsing fails
      return DateTime(date.year, date.month, date.day, 12, 0);
    }
  }

  /// Returns default prayer times when API is unavailable
  static PrayerTimesData _getDefaultPrayerTimes(DateTime date) {
    print('Using fallback prayer times - API unavailable');

    final prayerTimes = {
      'Fajr': DateTime(date.year, date.month, date.day, 4, 51, 0),
      'Sunrise': DateTime(date.year, date.month, date.day, 6, 7, 0),
      'Dhuhr': DateTime(date.year, date.month, date.day, 12, 41, 0),
      'Asr': DateTime(date.year, date.month, date.day, 17, 12, 0),
      'Maghrib': DateTime(date.year, date.month, date.day, 19, 14, 0),
      'Isha': DateTime(date.year, date.month, date.day, 20, 30, 0),
    };

    return PrayerTimesData(
      prayerTimes: prayerTimes,
      islamicDate: "1 Safar, 1447",
      gregorianDate: date,
      isDefault: true,
    );
  }

  /// Gets current and next prayer information
  static PrayerStatus getCurrentPrayerStatus(Map<String, DateTime> prayerTimes, DateTime currentTime) {
    if (prayerTimes.isEmpty) {
      return PrayerStatus(
        currentPrayer: "None",
        nextPrayer: "Fajr",
        timeRemaining: Duration.zero,
        progress: 0.0,
      );
    }

    String current = "None";
    String next = "Fajr";
    Duration remaining = Duration.zero;

    // Get prayers excluding Sunrise for prayer status
    List<MapEntry<String, DateTime>> prayers = prayerTimes.entries
        .where((entry) => entry.key != 'Sunrise')
        .toList();

    prayers.sort((a, b) => a.value.compareTo(b.value));

    // Find current and next prayer
    for (int i = 0; i < prayers.length; i++) {
      if (currentTime.isBefore(prayers[i].value)) {
        next = prayers[i].key;
        remaining = prayers[i].value.difference(currentTime);

        if (i > 0) {
          current = prayers[i - 1].key;
        } else {
          current = "Isha"; // Before Fajr means we're in Isha time
        }
        break;
      }
    }

    // If after all prayers (after Isha)
    if (currentTime.isAfter(prayers.last.value)) {
      current = prayers.last.key;
      next = "Fajr";
      final tomorrow = DateTime(currentTime.year, currentTime.month, currentTime.day + 1);
      final fajrTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day,
          prayerTimes['Fajr']!.hour, prayerTimes['Fajr']!.minute);
      remaining = fajrTomorrow.difference(currentTime);
    }

    // Calculate progress
    double progress = _calculateProgress(prayerTimes, currentTime, current, next);

    return PrayerStatus(
      currentPrayer: current,
      nextPrayer: next,
      timeRemaining: remaining,
      progress: progress,
    );
  }

  /// Calculates progress between current and next prayer
  static double _calculateProgress(
      Map<String, DateTime> prayerTimes,
      DateTime currentTime,
      String currentPrayer,
      String nextPrayer,
      ) {
    try {
      DateTime? currentPrayerTime;
      DateTime? nextPrayerTime;

      List<MapEntry<String, DateTime>> prayers = prayerTimes.entries
          .where((entry) => entry.key != 'Sunrise')
          .toList();
      prayers.sort((a, b) => a.value.compareTo(b.value));

      // Find current and next prayer times
      for (int i = 0; i < prayers.length; i++) {
        if (currentTime.isBefore(prayers[i].value)) {
          nextPrayerTime = prayers[i].value;
          if (i > 0) {
            currentPrayerTime = prayers[i - 1].value;
          } else {
            // Before Fajr, current prayer is Isha from previous day
            final yesterday = DateTime(currentTime.year, currentTime.month, currentTime.day - 1);
            currentPrayerTime = DateTime(yesterday.year, yesterday.month, yesterday.day,
                prayerTimes['Isha']!.hour, prayerTimes['Isha']!.minute);
          }
          break;
        }
      }

      // After Isha
      if (currentTime.isAfter(prayers.last.value)) {
        currentPrayerTime = prayers.last.value;
        final tomorrow = DateTime(currentTime.year, currentTime.month, currentTime.day + 1);
        nextPrayerTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day,
            prayerTimes['Fajr']!.hour, prayerTimes['Fajr']!.minute);
      }

      if (currentPrayerTime != null && nextPrayerTime != null) {
        final totalDuration = nextPrayerTime.difference(currentPrayerTime);
        final elapsedDuration = currentTime.difference(currentPrayerTime);
        return (elapsedDuration.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
      }

      return 0.0;
    } catch (e) {
      print('Error calculating progress: $e');
      return 0.0;
    }
  }

  /// Formats time for display
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  /// Formats current time with seconds
  static String formatCurrentTime(DateTime time) {
    return DateFormat('hh:mm:ss a').format(time);
  }
}

/// Data class to hold prayer times information
class PrayerTimesData {
  final Map<String, DateTime> prayerTimes;
  final String islamicDate;
  final DateTime gregorianDate;
  final bool isDefault;

  PrayerTimesData({
    required this.prayerTimes,
    required this.islamicDate,
    required this.gregorianDate,
    required this.isDefault,
  });

  @override
  String toString() {
    return 'PrayerTimesData(islamicDate: $islamicDate, isDefault: $isDefault, times: ${prayerTimes.length})';
  }
}

/// Data class to hold current prayer status
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

  @override
  String toString() {
    return 'PrayerStatus(current: $currentPrayer, next: $nextPrayer, remaining: ${timeRemaining.inMinutes}min)';
  }
}