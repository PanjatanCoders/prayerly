// services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static const double _defaultLatitude = 18.5204; // Pune coordinates
  static const double _defaultLongitude = 73.8567;
  static const String _defaultLocation = "Pune, Maharashtra";

  /// Gets current location with proper error handling
  static Future<LocationData> getCurrentLocation() async {
    try {
      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {

        const LocationSettings locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        );

        Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );

        // Get address from coordinates
        String address = await _getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
          isDefault: false,
        );
      } else {
        // Permission denied, use default location
        return _getDefaultLocation();
      }
    } catch (e) {
      print('Error getting location: $e');
      return _getDefaultLocation();
    }
  }

  /// Gets address from coordinates using reverse geocoding
  static Future<String> _getAddressFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        // Build address string with available components
        List<String> addressParts = [];

        if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        return addressParts.isNotEmpty
            ? addressParts.join(', ')
            : "Unknown location";
      } else {
        return "Unknown location";
      }
    } catch (e) {
      print('Error getting address: $e');
      return "Location unavailable";
    }
  }

  /// Returns default location data
  static LocationData _getDefaultLocation() {
    return LocationData(
      latitude: _defaultLatitude,
      longitude: _defaultLongitude,
      address: _defaultLocation,
      isDefault: true,
    );
  }

  /// Checks if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Gets current location permission status
  static Future<LocationPermission> getLocationPermission() async {
    return await Geolocator.checkPermission();
  }
}

/// Data class to hold location information
class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final bool isDefault;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isDefault,
  });

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $address, default: $isDefault)';
  }

  /// Creates a copy with updated values
  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? address,
    bool? isDefault,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}