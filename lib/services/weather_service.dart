// services/weather_service.dart
import 'dart:convert';

import 'package:flutter/material.dart' show IconData, Icons;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// A snapshot of current weather, used to decide how the circular timer's
/// sky should look ("show cloudy when it's actually cloudy") and to show the
/// current temperature/conditions on the hero card. Never influences prayer
/// time calculations.
class WeatherSnapshot {
  /// 0-100.
  final double cloudCoverPercent;

  /// WMO weather code (https://open-meteo.com/en/docs - see "WMO Weather
  /// interpretation codes"). 0 is clear sky; 51 and above is rain/snow/storm.
  final int weatherCode;

  /// Degrees Celsius.
  final double temperatureCelsius;
  final DateTime fetchedAt;

  const WeatherSnapshot({
    required this.cloudCoverPercent,
    required this.weatherCode,
    required this.temperatureCelsius,
    required this.fetchedAt,
  });

  double get cloudFraction => (cloudCoverPercent / 100).clamp(0.0, 1.0);

  bool get isPrecipitating => weatherCode >= 51;

  /// A short human label for [weatherCode], per Open-Meteo's WMO code table.
  String get description {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 2) return 'Partly cloudy';
    if (weatherCode == 3) return 'Overcast';
    if (weatherCode == 45 || weatherCode == 48) return 'Foggy';
    if (weatherCode <= 57) return 'Drizzle';
    if (weatherCode <= 67) return 'Rain';
    if (weatherCode <= 77) return 'Snow';
    if (weatherCode <= 82) return 'Rain showers';
    if (weatherCode <= 86) return 'Snow showers';
    return 'Thunderstorm';
  }

  /// The icon that best matches [weatherCode] (falls back to cloud cover for
  /// the plain "0-3" clear/cloudy codes, since Open-Meteo doesn't split those
  /// further).
  IconData get icon {
    if (weatherCode >= 95) return Icons.thunderstorm;
    if (weatherCode >= 71) return Icons.ac_unit;
    if (weatherCode >= 51) return Icons.grain;
    if (weatherCode == 45 || weatherCode == 48) return Icons.foggy;
    if (weatherCode >= 3 || cloudFraction > 0.5) return Icons.cloud;
    if (weatherCode >= 1) return Icons.wb_cloudy;
    return Icons.wb_sunny;
  }

  Map<String, dynamic> toJson() => {
        'cloudCoverPercent': cloudCoverPercent,
        'weatherCode': weatherCode,
        'temperatureCelsius': temperatureCelsius,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  static WeatherSnapshot? fromJson(Map<String, dynamic> json) {
    final cloud = (json['cloudCoverPercent'] as num?)?.toDouble();
    final code = (json['weatherCode'] as num?)?.toInt();
    final temperature = (json['temperatureCelsius'] as num?)?.toDouble();
    final fetchedAt = DateTime.tryParse(json['fetchedAt'] as String? ?? '');
    if (cloud == null || code == null || temperature == null || fetchedAt == null) {
      return null;
    }
    return WeatherSnapshot(
      cloudCoverPercent: cloud,
      weatherCode: code,
      temperatureCelsius: temperature,
      fetchedAt: fetchedAt,
    );
  }
}

/// Cloud cover for the circular timer's sky rendering.
///
/// Best-effort only, exactly like [ElevationService] or the reverse-geocoded
/// address: this is purely cosmetic enrichment, so a failure (offline, API
/// down, timeout) must never throw or block anything - every path here
/// returns the last cached snapshot (possibly null) instead.
class WeatherService {
  static const String _cacheKey = 'cached_weather_v1';

  /// Open-Meteo's own forecast refresh cadence is hourly; no point asking
  /// more often than that, and it keeps this off the critical path on every
  /// screen refresh.
  static const Duration _cacheFreshFor = Duration(minutes: 30);
  static const Duration _timeout = Duration(seconds: 6);

  static Future<WeatherSnapshot?> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    final cached = await _readCache();
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) < _cacheFreshFor) {
      return cached;
    }

    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'current': 'temperature_2m,cloud_cover,weather_code',
      });
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return cached;

      final body = json.decode(response.body) as Map<String, dynamic>;
      final current = body['current'] as Map<String, dynamic>?;
      final cloud = (current?['cloud_cover'] as num?)?.toDouble();
      final code = (current?['weather_code'] as num?)?.toInt();
      final temperature = (current?['temperature_2m'] as num?)?.toDouble();
      if (cloud == null || code == null || temperature == null) return cached;

      final snapshot = WeatherSnapshot(
        cloudCoverPercent: cloud,
        weatherCode: code,
        temperatureCelsius: temperature,
        fetchedAt: DateTime.now(),
      );
      await _writeCache(snapshot);
      return snapshot;
    } catch (_) {
      return cached;
    }
  }

  static Future<WeatherSnapshot?> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      return WeatherSnapshot.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeCache(WeatherSnapshot snapshot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(snapshot.toJson()));
    } catch (_) {
      // Ignore cache errors - the fetched value is still returned to the caller.
    }
  }
}
