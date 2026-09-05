// models/qibla_data.dart

import 'package:flutter/foundation.dart';

import '../services/compass_service.dart';
import 'location_data.dart';

/// One frame of Qibla state: where the Kaaba is, and where the user is facing.
///
/// [qiblaBearing] is available as soon as a location is known, with or without
/// a compass. [heading] is null until the sensor produces a sample, so the
/// screen can show a useful bearing on devices with no magnetometer instead of
/// failing outright.
@immutable
class QiblaReading {
  /// Great-circle bearing from the user to the Kaaba, 0-360 clockwise from
  /// north.
  final double qiblaBearing;

  /// Great-circle distance to the Kaaba in kilometres.
  final double distanceKm;

  /// Current device heading in degrees from north, or null when no compass
  /// sample has arrived yet.
  final double? heading;

  /// Sensor confidence for [heading].
  final CompassAccuracy accuracy;

  /// The location these values were derived from, including how it was
  /// obtained, so the UI can flag a stale or default position.
  final LocationData location;

  final DateTime timestamp;

  const QiblaReading({
    required this.qiblaBearing,
    required this.distanceKm,
    required this.heading,
    required this.accuracy,
    required this.location,
    required this.timestamp,
  });

  /// Within this many degrees the user is treated as facing the Qibla.
  ///
  /// Tighter than this is beyond what a phone magnetometer can resolve, and
  /// the fiqh position is that facing the general direction suffices.
  static const double alignmentToleranceDegrees = 5.0;

  bool get hasHeading => heading != null;

  /// Signed angle the user must still turn, in -180..180.
  ///
  /// Negative means turn left (anticlockwise), positive means turn right.
  /// **Zero means aligned** - the previous implementation treated 180 as
  /// aligned, which told users they were on target while facing away from
  /// the Kaaba.
  double? get turnAngle {
    final current = heading;
    if (current == null) return null;
    return CompassService.shortestDelta(current, qiblaBearing);
  }

  /// How far off the Qibla the user is, 0-180.
  double? get offsetDegrees => turnAngle?.abs();

  bool get isAligned {
    final offset = offsetDegrees;
    return offset != null && offset <= alignmentToleranceDegrees;
  }

  /// True when the sensor is disturbed enough that the user should calibrate.
  bool get needsCalibration => accuracy == CompassAccuracy.low;

  QiblaReading copyWith({
    double? heading,
    CompassAccuracy? accuracy,
    DateTime? timestamp,
  }) {
    return QiblaReading(
      qiblaBearing: qiblaBearing,
      distanceKm: distanceKm,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      location: location,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() =>
      'QiblaReading(qibla: ${qiblaBearing.toStringAsFixed(1)}deg, '
      'heading: ${heading?.toStringAsFixed(1)}, '
      'distance: ${distanceKm.toStringAsFixed(0)}km, '
      'accuracy: ${accuracy.name})';
}
