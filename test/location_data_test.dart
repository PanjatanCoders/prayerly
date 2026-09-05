import 'package:flutter_test/flutter_test.dart';
import 'package:prayerly/models/location_data.dart';

void main() {
  group('LocationData', () {
    test('round-trips through JSON and comes back tagged as cached', () {
      final original = LocationData(
        latitude: 23.8103,
        longitude: 90.4125,
        address: 'Dhaka, Bangladesh',
        source: LocationSource.gps,
        resolvedAt: DateTime(2026, 3, 15, 10, 30),
      );

      final restored = LocationData.fromJson(original.toJson())!;

      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.address, original.address);
      expect(restored.resolvedAt, original.resolvedAt);
      // A replayed fix is never a live one, however it was stored.
      expect(restored.source, LocationSource.cache);
    });

    test('rejects malformed payloads instead of throwing', () {
      expect(LocationData.fromJson(const {}), isNull);
      expect(LocationData.fromJson(const {'latitude': 1.0}), isNull);
    });

    test('falls back to coordinates when there is no address', () {
      final location = LocationData(
        latitude: 23.8103,
        longitude: 90.4125,
        address: '',
        source: LocationSource.lastKnown,
        resolvedAt: DateTime(2026),
      );

      expect(location.formattedCoordinates, '23.8103, 90.4125');
      expect(location.coarseKey, '23.81,90.41');
    });

    test('classifies sources', () {
      expect(LocationSource.gps.isLive, isTrue);
      expect(LocationSource.cache.isLive, isFalse);
      expect(LocationSource.cache.isUserLocation, isTrue);
      expect(LocationSource.fallback.isUserLocation, isFalse);
    });
  });
}
