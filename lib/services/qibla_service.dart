// services/qibla_service.dart
//
// Qibla domain logic: pure geodesy, plus the composition of a location and a
// heading stream into renderable [QiblaReading]s.
//
// Deliberate split of responsibilities:
//   * LocationService  - where the user is (offline-capable, never throws)
//   * CompassService   - which way the device points (smoothed, throttled)
//   * QiblaService     - the maths, and the join of the two above
//
// A note on north: Android reports headings relative to *magnetic* north,
// while the Qibla bearing computed here is a true (geodetic) bearing. The two
// differ by the local magnetic declination - under 3 degrees across South
// Asia, but up to ~20 degrees elsewhere. Until a declination model is added,
// [magneticDeclinationDegrees] is the single seam to correct it, and the UI
// states which north it is showing.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' show LocationPermission;

import '../models/qibla_data.dart';
import 'compass_service.dart';
import 'location_service.dart';

/// Why the compass could not be shown. Typed so the UI can render the right
/// remedy instead of pattern-matching on exception text.
enum QiblaFailure {
  locationPermissionDenied,
  locationPermissionDeniedForever,
  locationUnavailable,
  compassUnavailable,
}

class QiblaException implements Exception {
  final QiblaFailure failure;

  const QiblaException(this.failure);

  @override
  String toString() => 'QiblaException(${failure.name})';
}

class QiblaService {
  /// Kaaba coordinates (Masjid al-Haram, Makkah).
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  static const double _earthRadiusKm = 6371.0088;

  /// Correction applied to raw sensor headings to convert magnetic north to
  /// true north. Zero until a declination model is wired in; kept as a single
  /// named seam so that change touches one line.
  static const double magneticDeclinationDegrees = 0.0;

  // ---------------------------------------------------------------------------
  // Geodesy
  // ---------------------------------------------------------------------------

  /// Initial great-circle bearing from a point to the Kaaba, 0-360 clockwise
  /// from north.
  static double bearingToKaaba(double latitude, double longitude) {
    final lat1 = _rad(latitude);
    final lat2 = _rad(kaabaLatitude);
    final deltaLng = _rad(kaabaLongitude - longitude);

    final y = math.sin(deltaLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);

    return CompassService.normalize(_deg(math.atan2(y, x)));
  }

  /// Great-circle distance to the Kaaba in kilometres (haversine).
  static double distanceToKaabaKm(double latitude, double longitude) {
    final lat1 = _rad(latitude);
    final lat2 = _rad(kaabaLatitude);
    final dLat = _rad(kaabaLatitude - latitude);
    final dLng = _rad(kaabaLongitude - longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);

    return _earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// 16-point compass label for a bearing.
  static String cardinalFor(double bearing) {
    const points = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
    ];
    final index =
        ((CompassService.normalize(bearing) + 11.25) / 22.5).floor() % 16;
    return points[index];
  }

  // ---------------------------------------------------------------------------
  // Composition
  // ---------------------------------------------------------------------------

  /// Resolves the location to calculate the Qibla from.
  ///
  /// Delegates to [LocationService], so the compass inherits the same offline
  /// behaviour as the prayer screen: a cached or last-known fix is used when
  /// no live one is available. Throws [QiblaException] only when there is no
  /// usable position at all.
  static Future<LocationData> resolveLocation({
    BuildContext? context,
    bool forceRefresh = false,
  }) async {
    final location = await LocationService.resolve(
      context: context,
      forceRefresh: forceRefresh,
    );

    if (location.source == LocationSource.fallback) {
      // A hard-coded fallback would point the user at the wrong sky; for a
      // compass that is worse than an honest error.
      throw QiblaException(await _diagnoseLocationFailure());
    }

    return location;
  }

  /// Distinguishes "you said no" from "the fix never arrived" so the error
  /// screen can offer the right remedy.
  static Future<QiblaFailure> _diagnoseLocationFailure() async {
    try {
      final permission = await LocationService.getLocationPermission();
      switch (permission) {
        case LocationPermission.deniedForever:
          return QiblaFailure.locationPermissionDeniedForever;
        case LocationPermission.denied:
          return QiblaFailure.locationPermissionDenied;
        default:
          return QiblaFailure.locationUnavailable;
      }
    } catch (_) {
      return QiblaFailure.locationUnavailable;
    }
  }

  /// A stream of Qibla state for [location].
  ///
  /// Emits one heading-less frame immediately so the bearing and distance
  /// render without waiting for the sensor, then one frame per smoothed
  /// compass sample.
  static Stream<QiblaReading> watch(LocationData location) {
    final bearing = bearingToKaaba(location.latitude, location.longitude);
    final distance = distanceToKaabaKm(location.latitude, location.longitude);

    QiblaReading frame(HeadingReading? sample) => QiblaReading(
          qiblaBearing: bearing,
          distanceKm: distance,
          heading: sample == null
              ? null
              : CompassService.normalize(
                  sample.degrees + magneticDeclinationDegrees,
                ),
          accuracy: sample?.accuracy ?? CompassAccuracy.unknown,
          location: location,
          timestamp: DateTime.now(),
        );

    final controller = StreamController<QiblaReading>();
    StreamSubscription<HeadingReading>? subscription;

    controller.onListen = () {
      controller.add(frame(null));

      if (!CompassService.isSupported) return;

      subscription = CompassService.headings().listen(
        (sample) => controller.add(frame(sample)),
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('QiblaService: compass stream error ($error)');
          // A sensor hiccup must not tear down the screen: the bearing and
          // distance are still valid, so keep the stream alive.
        },
        cancelOnError: false,
      );
    };

    controller.onCancel = () async {
      await subscription?.cancel();
      subscription = null;
    };

    return controller.stream;
  }

  static double _rad(double degrees) => degrees * math.pi / 180;

  static double _deg(double radians) => radians * 180 / math.pi;
}
