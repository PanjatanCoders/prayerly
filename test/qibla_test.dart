import 'package:flutter_test/flutter_test.dart';
import 'package:prayerly/models/location_data.dart';
import 'package:prayerly/models/qibla_data.dart';
import 'package:prayerly/services/compass_service.dart';
import 'package:prayerly/services/qibla_service.dart';

LocationData _at(double lat, double lng) => LocationData(
      latitude: lat,
      longitude: lng,
      address: '',
      source: LocationSource.gps,
      resolvedAt: DateTime(2026),
    );

QiblaReading _reading({
  required double qiblaBearing,
  required double? heading,
}) =>
    QiblaReading(
      qiblaBearing: qiblaBearing,
      distanceKm: 1000,
      heading: heading,
      accuracy: CompassAccuracy.high,
      location: _at(23.8103, 90.4125),
      timestamp: DateTime(2026),
    );

void main() {
  group('angle helpers', () {
    test('normalize wraps into 0-360', () {
      expect(CompassService.normalize(0), 0);
      expect(CompassService.normalize(370), closeTo(10, 1e-9));
      expect(CompassService.normalize(-10), closeTo(350, 1e-9));
    });

    test('shortestDelta takes the short way around north', () {
      expect(CompassService.shortestDelta(350, 10), closeTo(20, 1e-9));
      expect(CompassService.shortestDelta(10, 350), closeTo(-20, 1e-9));
      expect(CompassService.shortestDelta(0, 180).abs(), closeTo(180, 1e-9));
    });
  });

  group('bearing to the Kaaba', () {
    test('Dhaka points roughly west-north-west', () {
      final bearing = QiblaService.bearingToKaaba(23.8103, 90.4125);
      expect(bearing, closeTo(278.4, 1.5));
    });

    test('Jakarta points roughly west-north-west', () {
      final bearing = QiblaService.bearingToKaaba(-6.2088, 106.8456);
      expect(bearing, closeTo(295.1, 1.5));
    });

    test('London points roughly south-east', () {
      final bearing = QiblaService.bearingToKaaba(51.5074, -0.1278);
      expect(bearing, closeTo(118.9, 1.5));
    });

    test('due north of the Kaaba points due south', () {
      final bearing = QiblaService.bearingToKaaba(
        QiblaService.kaabaLatitude + 10,
        QiblaService.kaabaLongitude,
      );
      expect(bearing, closeTo(180, 0.01));
    });
  });

  group('distance to the Kaaba', () {
    test('Dhaka is about 5170 km away', () {
      expect(QiblaService.distanceToKaabaKm(23.8103, 90.4125),
          closeTo(5172, 40));
    });

    test('the Kaaba is zero km from itself', () {
      expect(
        QiblaService.distanceToKaabaKm(
          QiblaService.kaabaLatitude,
          QiblaService.kaabaLongitude,
        ),
        closeTo(0, 0.001),
      );
    });
  });

  group('alignment', () {
    test('zero offset is aligned, and 180 degrees is not', () {
      // Regression: the old getAccuracyStatus reported "Perfect Alignment"
      // at a 180 degree offset, i.e. while facing away from the Kaaba.
      expect(_reading(qiblaBearing: 270, heading: 270).isAligned, isTrue);
      expect(_reading(qiblaBearing: 270, heading: 90).isAligned, isFalse);
    });

    test('turn angle is signed and takes the short way round', () {
      expect(_reading(qiblaBearing: 10, heading: 350).turnAngle,
          closeTo(20, 1e-9));
      expect(_reading(qiblaBearing: 350, heading: 10).turnAngle,
          closeTo(-20, 1e-9));
    });

    test('tolerance covers small errors only', () {
      expect(_reading(qiblaBearing: 100, heading: 96).isAligned, isTrue);
      expect(_reading(qiblaBearing: 100, heading: 90).isAligned, isFalse);
    });

    test('no heading means no guidance, not false alignment', () {
      final reading = _reading(qiblaBearing: 270, heading: null);
      expect(reading.hasHeading, isFalse);
      expect(reading.turnAngle, isNull);
      expect(reading.isAligned, isFalse);
    });
  });

  group('cardinal labels', () {
    test('map bearings to the nearest of 16 points', () {
      expect(QiblaService.cardinalFor(0), 'N');
      expect(QiblaService.cardinalFor(359), 'N');
      expect(QiblaService.cardinalFor(90), 'E');
      expect(QiblaService.cardinalFor(225), 'SW');
      expect(QiblaService.cardinalFor(278), 'W');
    });
  });
}
