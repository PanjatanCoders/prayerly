import 'dart:convert';
import 'package:http/http.dart' as http;

class ElevationService {
  static const String _baseUrl = 'https://api.open-elevation.com/api/v1/lookup';

  /// Fetches elevation data for given coordinates
  /// Returns elevation in meters
  static Future<double?> getElevation(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?locations=$latitude,$longitude'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final elevation = data['results'][0]['elevation'];
          return elevation?.toDouble();
        }
      }

      // Fallback to alternative API if first one fails
      return await _getElevationFallback(latitude, longitude);
    } catch (e) {
      print('Error fetching elevation from primary API: $e');
      return await _getElevationFallback(latitude, longitude);
    }
  }

  /// Fallback elevation service using a different API
  static Future<double?> _getElevationFallback(double latitude, double longitude) async {
    try {
      // Using USGS Elevation Point Query Service as fallback
      final response = await http.get(
        Uri.parse('https://nationalmap.gov/epqs/pqs.php?x=$longitude&y=$latitude&units=Meters&output=json'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['USGS_Elevation_Point_Query_Service'] != null &&
            data['USGS_Elevation_Point_Query_Service']['Elevation_Query'] != null) {
          final elevation = data['USGS_Elevation_Point_Query_Service']['Elevation_Query']['Elevation'];
          return double.tryParse(elevation.toString());
        }
      }
    } catch (e) {
      print('Error fetching elevation from fallback API: $e');
    }

    return null; // Return null if all attempts fail
  }

  /// Formats elevation for display
  static String formatElevation(double? elevation, {bool showUnit = true}) {
    if (elevation == null) {
      return "Elevation unavailable";
    }

    if (showUnit) {
      return "${elevation.toStringAsFixed(1)} m";
    }

    return elevation.toStringAsFixed(1);
  }

  /// Converts meters to feet
  static double metersToFeet(double meters) {
    return meters * 3.28084;
  }

  /// Formats elevation in both meters and feet
  static String formatElevationWithBothUnits(double? elevation) {
    if (elevation == null) {
      return "Elevation unavailable";
    }

    final feet = metersToFeet(elevation);
    return "${elevation.toStringAsFixed(1)} m (${feet.toStringAsFixed(1)} ft)";
  }
}