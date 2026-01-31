// services/elevation_service.dart
// Offline elevation service - no API calls
import 'package:shared_preferences/shared_preferences.dart';

class ElevationService {
  static const String _cacheKey = 'cached_elevation';
  static const String _cacheLocationKey = 'cached_elevation_location';

  /// Returns cached elevation or default value - NO INTERNET REQUIRED
  static Future<double?> getElevation(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedLocation = prefs.getString(_cacheLocationKey);
      final cachedElevation = prefs.getDouble(_cacheKey);

      if (cachedLocation != null && cachedElevation != null) {
        final parts = cachedLocation.split(',');
        final cachedLat = double.parse(parts[0]);
        final cachedLng = double.parse(parts[1]);

        // Return cached value if location is close (within ~10km)
        if ((latitude - cachedLat).abs() < 0.1 && (longitude - cachedLng).abs() < 0.1) {
          return cachedElevation;
        }
      }

      // Return default elevation (sea level) for offline use
      // Elevation has minimal impact on prayer times for most locations
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Cache elevation value (can be called when online)
  static Future<void> cacheElevation(double latitude, double longitude, double elevation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_cacheKey, elevation);
      await prefs.setString(_cacheLocationKey, '$latitude,$longitude');
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Formats elevation for display
  static String formatElevation(double? elevation, {bool showUnit = true}) {
    if (elevation == null) {
      return "Sea level";
    }

    if (showUnit) {
      return "${elevation.toStringAsFixed(0)} m";
    }

    return elevation.toStringAsFixed(0);
  }

  /// Converts meters to feet
  static double metersToFeet(double meters) {
    return meters * 3.28084;
  }

  /// Formats elevation in both meters and feet
  static String formatElevationWithBothUnits(double? elevation) {
    if (elevation == null || elevation == 0) {
      return "Sea level";
    }

    final feet = metersToFeet(elevation);
    return "${elevation.toStringAsFixed(0)} m (${feet.toStringAsFixed(0)} ft)";
  }
}
