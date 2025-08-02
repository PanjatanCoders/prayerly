// services/prayer_service.dart
// ignore_for_file: unused_local_variable, avoid_print, unnecessary_brace_in_string_interps, depend_on_referenced_packages

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class PrayerService {
  static const String _baseUrl = 'https://api.aladhan.com/v1/timings';
  
  // Use Hanafi method by default
  static const bool _useHanafiMethod = true;
  
  /// Get prayer times for given coordinates
  static Future<PrayerTimesData> getPrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    
    try {
      // Format date for API
      final String formattedDate = 
          '${targetDate.day.toString().padLeft(2, '0')}-'
          '${targetDate.month.toString().padLeft(2, '0')}-'
          '${targetDate.year}';
      
      // Use method 1 (University of Islamic Sciences, Karachi) for Hanafi
      // and school parameter 1 for Hanafi Asr calculation
      final String url = '$_baseUrl/$formattedDate'
          '?latitude=$latitude'
          '&longitude=$longitude'
          '&method=1'  // Karachi method (Hanafi friendly)
          '&school=1'; // 1 = Hanafi, 0 = Shafi
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        final dateInfo = data['data']['date'];
        
        // Parse prayer times
        final Map<String, DateTime> prayerTimes = {};
        
        prayerTimes['Fajr'] = _parseTime(timings['Fajr'], targetDate);
        prayerTimes['Sunrise'] = _parseTime(timings['Sunrise'], targetDate);
        prayerTimes['Dhuhr'] = _parseTime(timings['Dhuhr'], targetDate);
        prayerTimes['Asr'] = _parseTime(timings['Asr'], targetDate);
        prayerTimes['Maghrib'] = _parseTime(timings['Maghrib'], targetDate);
        prayerTimes['Isha'] = _parseTime(timings['Isha'], targetDate);
        
        // Double-check Asr time with manual Hanafi calculation
        if (_useHanafiMethod) {
          final calculatedAsr = _calculateHanafiAsr(
            latitude: latitude,
            longitude: longitude,
            date: targetDate,
          );
          
          // Use the later time (API or calculated) for safety
          if (calculatedAsr.isAfter(prayerTimes['Asr']!)) {
            prayerTimes['Asr'] = calculatedAsr;
          }
        }
        
        // Get Islamic date
        final hijriDate = dateInfo['hijri'];
        final islamicDate = '${hijriDate['day']} ${hijriDate['month']['en']} ${hijriDate['year']}';
        
        return PrayerTimesData(
          prayerTimes: prayerTimes,
          islamicDate: islamicDate,
          isDefault: false,
        );
        
      } else {
        throw Exception('Failed to fetch prayer times: ${response.statusCode}');
      }
      
    } catch (e) {
      print('Error fetching prayer times: $e');
      
      // Fallback to manual calculation
      return _calculatePrayerTimesManually(
        latitude: latitude,
        longitude: longitude,
        date: targetDate,
      );
    }
  }
  
  /// Manual Hanafi Asr calculation
  static DateTime _calculateHanafiAsr({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    try {
      // Convert to radians
      final double lat = latitude * (pi / 180);
      final double lng = longitude * (pi / 180);
      
      // Day of year
      final int dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
      
      // Solar declination
      final double declination = 23.45 * 
          sin((360 * (284 + dayOfYear) / 365) * (pi / 180)) * (pi / 180);
      
      // Equation of time
      final double eqTime = 4 * (longitude - 15 * (longitude / 15).round());
      
      // Solar noon
      final double solarNoon = 12 - eqTime / 60;
      
      // Calculate noon altitude
      final double noonAltitude = asin(
        sin(declination) * sin(lat) + cos(declination) * cos(lat)
      );
      
      // Hanafi method: shadow = 2 * object height (plus noon shadow)
      // Standard method: shadow = 1 * object height (plus noon shadow)
      final double shadowFactor = 2.0; // Hanafi
      
      // Calculate Asr angle
      final double cotNoonAlt = 1 / tan(noonAltitude);
      final double asrAngle = atan(1 / (shadowFactor + cotNoonAlt));
      
      // Hour angle for Asr
      final double hourAngle = acos(
        (sin(asrAngle) - sin(lat) * sin(declination)) /
        (cos(lat) * cos(declination))
      ) * (180 / pi);
      
      // Asr time
      final double asrTime = solarNoon + hourAngle / 15;
      
      // Convert to DateTime
      final int hours = asrTime.floor();
      final int minutes = ((asrTime - hours) * 60).round();
      
      return DateTime(date.year, date.month, date.day, hours, minutes);
      
    } catch (e) {
      print('Error calculating Hanafi Asr: $e');
      // Fallback: add 1 hour to a standard calculation
      return DateTime(date.year, date.month, date.day, 15, 30);
    }
  }
  
  /// Manual calculation fallback
  static PrayerTimesData _calculatePrayerTimesManually({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    final Map<String, DateTime> prayerTimes = {};
    
    try {
      // Basic calculations (you can enhance these)
      final double lat = latitude * (pi / 180);
      final int dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
      final double declination = 23.45 * 
          sin((360 * (284 + dayOfYear) / 365) * (pi / 180)) * (pi / 180);
      final double eqTime = 4 * (longitude - 15 * (longitude / 15).round());
      final double solarNoon = 12 - eqTime / 60;
      
      // Fajr (18 degrees below horizon)
      prayerTimes['Fajr'] = _calculatePrayerTime(lat, declination, solarNoon, -18.0, true, date);
      
      // Sunrise
      prayerTimes['Sunrise'] = _calculatePrayerTime(lat, declination, solarNoon, -0.833, true, date);
      
      // Dhuhr (solar noon + 1 minute)
      final int noonHours = solarNoon.floor();
      final int noonMinutes = ((solarNoon - noonHours) * 60).round() + 1;
      prayerTimes['Dhuhr'] = DateTime(date.year, date.month, date.day, noonHours, noonMinutes);
      
      // Asr (Hanafi method)
      prayerTimes['Asr'] = _calculateHanafiAsr(
        latitude: latitude,
        longitude: longitude,
        date: date,
      );
      
      // Maghrib
      prayerTimes['Maghrib'] = _calculatePrayerTime(lat, declination, solarNoon, -0.833, false, date);
      
      // Isha (17 degrees below horizon)
      prayerTimes['Isha'] = _calculatePrayerTime(lat, declination, solarNoon, -17.0, false, date);
      
    } catch (e) {
      print('Error in manual calculation: $e');
      // Fallback times
      prayerTimes['Fajr'] = DateTime(date.year, date.month, date.day, 5, 30);
      prayerTimes['Sunrise'] = DateTime(date.year, date.month, date.day, 6, 45);
      prayerTimes['Dhuhr'] = DateTime(date.year, date.month, date.day, 12, 30);
      prayerTimes['Asr'] = DateTime(date.year, date.month, date.day, 15, 45); // Later time for Hanafi
      prayerTimes['Maghrib'] = DateTime(date.year, date.month, date.day, 18, 15);
      prayerTimes['Isha'] = DateTime(date.year, date.month, date.day, 19, 45);
    }
    
    return PrayerTimesData(
      prayerTimes: prayerTimes,
      islamicDate: _getDefaultIslamicDate(date),
      isDefault: true,
    );
  }
  
  /// Helper method for prayer time calculation
  static DateTime _calculatePrayerTime(
    double lat, 
    double declination, 
    double solarNoon, 
    double angle, 
    bool isBefore, 
    DateTime date
  ) {
    try {
      final double hourAngle = acos(
        (sin(angle * (pi / 180)) - sin(lat) * sin(declination)) /
        (cos(lat) * cos(declination))
      ) * (180 / pi);
      
      final double prayerTime = isBefore 
        ? solarNoon - hourAngle / 15
        : solarNoon + hourAngle / 15;
      
      final int hours = prayerTime.floor();
      final int minutes = ((prayerTime - hours) * 60).round();
      
      return DateTime(date.year, date.month, date.day, hours, minutes);
    } catch (e) {
      // Fallback
      return DateTime(date.year, date.month, date.day, 12, 0);
    }
  }
  
  /// Parse time string to DateTime
  static DateTime _parseTime(String timeStr, DateTime date) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
  
  /// Get default Islamic date
  static String _getDefaultIslamicDate(DateTime date) {
    // Simple approximation - you might want to use a proper Islamic calendar library
    final islamicYear = date.year - 579;
    return '${date.day} Hijri ${islamicYear}';
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
      final nextPrayerIndex = (i + 1) % prayers.length;
      final nextPrayerTime = prayerTimes[prayers[nextPrayerIndex]]!;
      
      if (currentTime.isBefore(prayerTime)) {
        // Next prayer is this one
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