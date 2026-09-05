// models/location_data.dart

/// Where a resolved [LocationData] came from.
///
/// The prayer-time screen must be able to render without a network and without
/// a fresh GPS fix, so location resolution degrades through these tiers in
/// order instead of failing.
enum LocationSource {
  /// A fresh fix from the device location provider.
  gps,

  /// The platform's last known fix; no new fix arrived in time.
  lastKnown,

  /// The last position this app persisted, replayed from disk.
  cache,

  /// A hard-coded fallback used when nothing else is available.
  fallback,
}

extension LocationSourceX on LocationSource {
  /// True when the coordinates actually belong to the user.
  bool get isUserLocation =>
      this == LocationSource.gps ||
      this == LocationSource.lastKnown ||
      this == LocationSource.cache;

  /// True when the coordinates are current enough to be trusted silently.
  bool get isLive => this == LocationSource.gps;
}

/// Immutable snapshot of the location prayer times are calculated for.
class LocationData {
  final double latitude;
  final double longitude;

  /// Human readable address. Purely cosmetic: it comes from reverse geocoding,
  /// which needs a network, so it is never allowed to block or fail a
  /// calculation. Falls back to a formatted coordinate pair.
  final String address;

  /// Which tier of the resolution chain produced these coordinates.
  final LocationSource source;

  /// When the underlying fix was taken (not when it was read from disk).
  final DateTime resolvedAt;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.source,
    required this.resolvedAt,
  });

  /// Retained for existing call sites: true when we are showing a stand-in
  /// location rather than the user's own.
  bool get isDefault => source == LocationSource.fallback;

  /// How long a stored fix stays good enough to present without comment.
  /// People rarely move far enough to change their Qibla or prayer times
  /// within a few hours.
  static const Duration freshFor = Duration(hours: 6);

  bool get isRecent => DateTime.now().difference(resolvedAt) < freshFor;

  /// True when we can show these coordinates without qualifying them: either
  /// a live fix, or a recent one belonging to this user.
  bool get isTrustworthy =>
      source.isLive || (source.isUserLocation && isRecent);

  /// Coordinates rounded to ~1 km, used as a cache key for address lookups.
  String get coarseKey =>
      '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}';

  String get formattedCoordinates =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? address,
    LocationSource? source,
    DateTime? resolvedAt,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      source: source ?? this.source,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'resolvedAt': resolvedAt.toIso8601String(),
      };

  /// Rebuilds a persisted location. Always tagged [LocationSource.cache]
  /// because a stored fix is by definition not a live one.
  static LocationData? fromJson(Map<String, dynamic> json) {
    final lat = (json['latitude'] as num?)?.toDouble();
    final lng = (json['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    return LocationData(
      latitude: lat,
      longitude: lng,
      address: (json['address'] as String?) ?? '',
      source: LocationSource.cache,
      resolvedAt:
          DateTime.tryParse(json['resolvedAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  String toString() =>
      'LocationData(lat: $latitude, lng: $longitude, address: $address, '
      'source: ${source.name}, resolvedAt: $resolvedAt)';
}
