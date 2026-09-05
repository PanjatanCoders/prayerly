// services/compass_service.dart
//
// Sensor layer for the compass. Deals only with "which way is the device
// pointing" - it knows nothing about the Qibla.
//
// Two things make a raw magnetometer feed unusable in a UI:
//
//   * it is noisy, so the needle jitters by several degrees at rest;
//   * it fires at sensor rate (50-100 Hz), so naively rebuilding on every
//     event burns battery and drops frames.
//
// This service fixes both: a circular exponential filter smooths the signal
// without the 0/360 wrap-around artefacts a plain average would produce, and
// output is throttled to display rate.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';

/// Coarse buckets for the sensor's self-reported deviation error.
enum CompassAccuracy {
  /// Deviation within a few degrees - safe to pray by.
  high,

  /// Usable, but worth calibrating.
  medium,

  /// The reading is being disturbed; the user must calibrate.
  low,

  /// The platform did not report an accuracy (common on Android).
  unknown,
}

/// A single smoothed heading sample.
@immutable
class HeadingReading {
  /// Smoothed heading in degrees, 0-360, where 0 is magnetic north.
  final double degrees;

  /// The unsmoothed value, kept for diagnostics.
  final double rawDegrees;

  /// Reported deviation error in degrees, or null when the platform does not
  /// provide one.
  final double? deviationDegrees;

  final DateTime timestamp;

  const HeadingReading({
    required this.degrees,
    required this.rawDegrees,
    required this.deviationDegrees,
    required this.timestamp,
  });

  CompassAccuracy get accuracy {
    final deviation = deviationDegrees;
    if (deviation == null || deviation < 0) return CompassAccuracy.unknown;
    if (deviation <= 5) return CompassAccuracy.high;
    if (deviation <= 15) return CompassAccuracy.medium;
    return CompassAccuracy.low;
  }

  /// True when the reading is too disturbed to be trusted.
  bool get needsCalibration => accuracy == CompassAccuracy.low;
}

class CompassService {
  /// Minimum gap between emitted samples. 60 Hz worth of updates is more than
  /// the eye can follow and more than the widget tree should absorb.
  static const Duration _minInterval = Duration(milliseconds: 40);

  /// Movement below this is sensor noise, not the user turning.
  static const double _minChangeDegrees = 0.15;

  /// True when the platform exposes a compass at all.
  ///
  /// This is a cheap structural check. Whether the sensor actually *produces*
  /// readings is decided by watching [headings] - callers should render a
  /// degraded state if no sample arrives, rather than probing the stream
  /// twice and paying for two native subscriptions.
  static bool get isSupported => FlutterCompass.events != null;

  /// A smoothed, throttled stream of device headings.
  ///
  /// Each subscription gets its own filter state, so two screens listening at
  /// once cannot corrupt each other's smoothing.
  static Stream<HeadingReading> headings() {
    final source = FlutterCompass.events;
    if (source == null) return const Stream<HeadingReading>.empty();

    // Filter state, private to this subscription.
    double? smoothedSin;
    double? smoothedCos;
    double? lastEmitted;
    DateTime lastEmittedAt = DateTime.fromMillisecondsSinceEpoch(0);

    return source.transform(
      StreamTransformer<CompassEvent, HeadingReading>.fromHandlers(
        handleData: (event, sink) {
          final raw = event.heading;
          if (raw == null || raw.isNaN) return;

          final normalised = normalize(raw);
          final radians = normalised * math.pi / 180;
          final sinValue = math.sin(radians);
          final cosValue = math.cos(radians);

          if (smoothedSin == null || smoothedCos == null) {
            smoothedSin = sinValue;
            smoothedCos = cosValue;
          } else {
            // Adaptive gain: track fast when the user is actually turning,
            // damp hard when they are holding still. A fixed alpha forces a
            // choice between a laggy needle and a jittery one.
            final delta = shortestDelta(
              _degreesFrom(smoothedSin!, smoothedCos!),
              normalised,
            ).abs();
            final alpha = _gainForDelta(delta);

            smoothedSin = smoothedSin! + alpha * (sinValue - smoothedSin!);
            smoothedCos = smoothedCos! + alpha * (cosValue - smoothedCos!);
          }

          final smoothed = _degreesFrom(smoothedSin!, smoothedCos!);
          final now = DateTime.now();

          // Throttle, but never swallow the very first sample.
          if (lastEmitted != null) {
            if (now.difference(lastEmittedAt) < _minInterval) return;
            if (shortestDelta(lastEmitted!, smoothed).abs() <
                _minChangeDegrees) {
              return;
            }
          }

          lastEmitted = smoothed;
          lastEmittedAt = now;

          sink.add(HeadingReading(
            degrees: smoothed,
            rawDegrees: normalised,
            deviationDegrees: event.accuracy,
            timestamp: now,
          ));
        },
        handleError: (error, stackTrace, sink) {
          debugPrint('CompassService: sensor error ($error)');
          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  /// Filter gain as a function of how far the reading moved.
  ///
  /// Small movements (noise) are damped heavily; large ones (a deliberate
  /// turn) pass through almost untouched so the needle keeps up.
  static double _gainForDelta(double deltaDegrees) {
    if (deltaDegrees > 45) return 0.9;
    if (deltaDegrees > 15) return 0.5;
    if (deltaDegrees > 5) return 0.25;
    return 0.12;
  }

  static double _degreesFrom(double sinValue, double cosValue) =>
      normalize(math.atan2(sinValue, cosValue) * 180 / math.pi);

  /// Wraps any angle into 0-360.
  static double normalize(double degrees) {
    final wrapped = degrees % 360;
    return wrapped < 0 ? wrapped + 360 : wrapped;
  }

  /// Signed difference from [from] to [to], in -180..180.
  ///
  /// Used everywhere an angle is compared or animated: taking the raw
  /// difference makes a needle spin the long way round when it crosses north.
  static double shortestDelta(double from, double to) {
    final delta = (to - from) % 360;
    if (delta > 180) return delta - 360;
    if (delta < -180) return delta + 360;
    return delta;
  }
}
