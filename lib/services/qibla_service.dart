// services/qibla_service.dart
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../models/qibla_data.dart';

/// Service for calculating Qibla direction and managing compass functionality
class QiblaService {
  /// Kaaba coordinates (Mecca, Saudi Arabia)
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  // Private variables for managing streams
  static StreamSubscription<CompassEvent>? _compassSubscription;
  static StreamController<QiblaData>? _qiblaController;

  /// Get current location with proper permission handling (foreground only)
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    // Check location permissions (whileInUse only - no background)
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable in settings.');
    }

    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      );
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (e) {
      throw Exception('Failed to get location: ${e.toString()}');
    }
  }

  /// Calculate Qibla direction using Great Circle bearing formula
  static double calculateQiblaDirection(double userLatitude, double userLongitude) {
    // Convert degrees to radians
    final userLatRad = _degreesToRadians(userLatitude);
    final userLngRad = _degreesToRadians(userLongitude);
    final kaabaLatRad = _degreesToRadians(kaabaLatitude);
    final kaabaLngRad = _degreesToRadians(kaabaLongitude);

    // Calculate difference in longitude
    final deltaLng = kaabaLngRad - userLngRad;

    // Calculate bearing using Great Circle formula
    final y = math.sin(deltaLng) * math.cos(kaabaLatRad);
    final x = math.cos(userLatRad) * math.sin(kaabaLatRad) -
        math.sin(userLatRad) * math.cos(kaabaLatRad) * math.cos(deltaLng);

    // Calculate initial bearing
    final initialBearing = math.atan2(y, x);

    // Convert to degrees and normalize to 0-360
    final bearing = _radiansToDegrees(initialBearing);
    return (bearing + 360) % 360;
  }

  /// Calculate distance to Kaaba in kilometers
  static double calculateDistanceToKaaba(double userLatitude, double userLongitude) {
    try {
      return Geolocator.distanceBetween(
          userLatitude,
          userLongitude,
          kaabaLatitude,
          kaabaLongitude
      ) / 1000; // Convert meters to kilometers
    } catch (e) {
      debugPrint('Error calculating distance to Kaaba: $e');
      return 0.0;
    }
  }

  /// Check if compass is available on this device
  static Future<bool> isCompassAvailable() async {
    try {
      final events = FlutterCompass.events;
      if (events == null) return false;
      
      // Try to get one compass reading to verify it works
      final completer = Completer<bool>();
      late StreamSubscription subscription;
      
      subscription = events.timeout(const Duration(seconds: 3)).listen(
        (event) {
          subscription.cancel();
          completer.complete(event.heading != null);
        },
        onError: (error) {
          subscription.cancel();
          completer.complete(false);
        },
      );
      
      return await completer.future;
    } catch (e) {
      debugPrint('Error checking compass availability: $e');
      return false;
    }
  }

  /// Get static Qibla information for a specific location
  static Future<QiblaData> getQiblaData(Position position) async {
    final qiblaDirection = calculateQiblaDirection(position.latitude, position.longitude);
    final distance = calculateDistanceToKaaba(position.latitude, position.longitude);

    return QiblaData(
      direction: qiblaDirection,
      distance: distance,
      bearing: qiblaDirection, // Initial bearing without compass
      calculatedAt: DateTime.now(),
    );
  }

  /// Start real-time Qibla compass stream
  static Stream<QiblaData> startQiblaCompass() async* {
    try {
      // Get user location first
      final position = await getCurrentLocation();
      final qiblaDirection = calculateQiblaDirection(position.latitude, position.longitude);
      final distance = calculateDistanceToKaaba(position.latitude, position.longitude);

      // Check if compass is available
      final compassEvents = FlutterCompass.events;
      if (compassEvents == null) {
        throw Exception('Compass not available on this device');
      }

      // Listen to compass updates and yield Qibla data
      await for (final compassEvent in compassEvents) {
        final compassHeading = compassEvent.heading;
        if (compassHeading == null) continue;

        // Calculate bearing relative to Qibla direction
        final qiblaBearing = (qiblaDirection - compassHeading + 360) % 360;

        yield QiblaData(
          direction: qiblaDirection,
          distance: distance,
          bearing: qiblaBearing,
          calculatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error in Qibla compass stream: $e');
      rethrow;
    }
  }

  /// Get formatted direction string (N, NE, E, etc.)
  static String getDirectionString(double bearing) {
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];

    final index = ((bearing + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Get Qibla accuracy status based on bearing alignment
  static String getAccuracyStatus(double bearing) {
    // Calculate how close the bearing is to perfect alignment (180°)
    final accuracy = (bearing - 180).abs();

    if (accuracy <= 2) {
      return 'Perfect Alignment';
    } else if (accuracy <= 5) {
      return 'Very Good';
    } else if (accuracy <= 10) {
      return 'Good';
    } else if (accuracy <= 15) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }

  /// Get emoji icon for cardinal direction
  static String getDirectionIcon(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return '⬆️'; // N
    if (bearing >= 22.5 && bearing < 67.5) return '↗️'; // NE
    if (bearing >= 67.5 && bearing < 112.5) return '➡️'; // E
    if (bearing >= 112.5 && bearing < 157.5) return '↘️'; // SE
    if (bearing >= 157.5 && bearing < 202.5) return '⬇️'; // S
    if (bearing >= 202.5 && bearing < 247.5) return '↙️'; // SW
    if (bearing >= 247.5 && bearing < 292.5) return '⬅️'; // W
    if (bearing >= 292.5 && bearing < 337.5) return '↖️'; // NW
    return '⬆️'; // Default
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Convert radians to degrees
  static double _radiansToDegrees(double radians) {
    return radians * (180 / math.pi);
  }

  /// Clean up resources and stop compass updates
  static void dispose() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    _qiblaController?.close();
    _qiblaController = null;
  }
}