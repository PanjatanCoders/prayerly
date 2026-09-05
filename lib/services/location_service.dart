// services/location_service.dart
//
// Single source of truth for "where is the user".
//
// Design contract: resolving a location NEVER throws and NEVER returns null.
// Prayer times are calculated entirely on-device, so the only thing that can
// stop the prayer screen from rendering is a missing coordinate. The resolver
// therefore degrades through four tiers - live fix, platform last-known fix,
// our own persisted fix, hard-coded fallback - and reports which tier it used
// so the UI can be honest about staleness.
//
// Reverse geocoding (address text) needs a network. It is deliberately kept
// out of the critical path: it runs separately, is cached, and a failure only
// costs a nicer label.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_data.dart';
import 'location_disclosure.dart';

export '../models/location_data.dart';

class LocationService {
  // Fallback used only when we have never had a fix and cannot get one.
  // The UI must label this as a default so the user is never silently shown
  // prayer times for somewhere they are not.
  static const double _fallbackLatitude = 18.5204; // Pune
  static const double _fallbackLongitude = 73.8567;
  static const String _fallbackAddress = 'Pune, Maharashtra';

  static const String _locationCacheKey = 'cached_location_v2';
  static const String _addressCachePrefix = 'cached_address_';

  /// How long we wait for a fresh fix before falling back. Offline devices
  /// have no network-assisted location, so an unbounded wait would hang the
  /// screen on a spinner forever - which is the bug this bounds.
  static const Duration _fixTimeout = Duration(seconds: 12);
  static const Duration _geocodeTimeout = Duration(seconds: 8);

  /// In-memory copy so repeated reads within a session are free.
  static LocationData? _inMemory;

  /// Guards against two concurrent resolutions (screen init + tab switch)
  /// both starting a GPS fix.
  static Future<LocationData>? _inFlight;

  /// Last position we successfully persisted, read from disk.
  ///
  /// Returns immediately and never triggers a fix, so callers can paint a
  /// first frame with real data while a fresh fix is still being acquired.
  static Future<LocationData?> cachedLocation() async {
    if (_inMemory != null) return _inMemory;
    return _readPersistedLocation();
  }

  /// Resolves the user's location, degrading gracefully. Never throws.
  ///
  /// Pass [context] so the Play-required prominent disclosure can be shown
  /// before the system permission prompt.
  static Future<LocationData> resolve({
    BuildContext? context,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh && _inFlight != null) return _inFlight!;

    final future = _resolve(context: context, forceRefresh: forceRefresh);
    _inFlight = future;
    return future.whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
  }

  static Future<LocationData> _resolve({
    BuildContext? context,
    required bool forceRefresh,
  }) async {
    final cached = await _readPersistedLocation();

    // A fix taken minutes ago is as good as a new one for prayer times, and
    // skipping the GPS round trip keeps the screen instant.
    if (!forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.resolvedAt) <
            const Duration(minutes: 15)) {
      _inMemory = cached;
      return cached;
    }

    // The awaits above may have outlived the caller's element.
    final live = await _tryLiveFix(
      context: context != null && context.mounted ? context : null,
    );
    if (live != null) {
      final withAddress = live.copyWith(
        address: await _cachedAddressFor(live) ?? live.formattedCoordinates,
      );
      await _persist(withAddress);
      _inMemory = withAddress;
      return withAddress;
    }

    if (cached != null) {
      _inMemory = cached;
      return cached;
    }

    final fallback = LocationData(
      latitude: _fallbackLatitude,
      longitude: _fallbackLongitude,
      address: _fallbackAddress,
      source: LocationSource.fallback,
      resolvedAt: DateTime.now(),
    );
    _inMemory = fallback;
    return fallback;
  }

  /// Attempts a device fix. Returns null when permission, hardware or time
  /// runs out - every failure here is expected, not exceptional.
  static Future<LocationData?> _tryLiveFix({BuildContext? context}) async {
    if (!await _ensurePermission(context: context)) return null;

    if (!await Geolocator.isLocationServiceEnabled()) {
      // GPS switched off entirely: skip the fix attempt but still try the
      // platform's last known position, which survives the switch.
      return _lastKnownFix();
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          distanceFilter: 500,
          timeLimit: _fixTimeout,
        ),
      ).timeout(_fixTimeout + const Duration(seconds: 2));

      return _fromPosition(position, LocationSource.gps);
    } catch (e) {
      debugPrint('LocationService: live fix failed ($e), trying last known');
      return _lastKnownFix();
    }
  }

  static Future<LocationData?> _lastKnownFix() async {
    try {
      final position = await Geolocator.getLastKnownPosition()
          .timeout(const Duration(seconds: 5));
      if (position == null) return null;
      return _fromPosition(position, LocationSource.lastKnown);
    } catch (e) {
      debugPrint('LocationService: last known position unavailable ($e)');
      return null;
    }
  }

  static LocationData _fromPosition(Position position, LocationSource source) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      address: '',
      source: source,
      resolvedAt: position.timestamp,
    );
  }

  /// Returns true when we hold a usable foreground location permission.
  static Future<bool> _ensurePermission({BuildContext? context}) async {
    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        if (context != null && context.mounted) {
          final consented = await LocationDisclosure.showIfNeeded(context);
          if (!consented) return false;
        }
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      debugPrint('LocationService: permission check failed ($e)');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Address (reverse geocoding) - cosmetic, network-dependent, never blocking.
  // ---------------------------------------------------------------------------

  /// Fills in a human readable address, preferring cache, then the network.
  ///
  /// Always returns a usable [LocationData]: on failure the address falls back
  /// to the coordinate pair rather than leaving the caller empty-handed.
  static Future<LocationData> withAddress(
    LocationData location, {
    String? unknownLabel,
  }) async {
    final cached = await _cachedAddressFor(location);
    if (cached != null && cached.isNotEmpty) {
      return location.copyWith(address: cached);
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      ).timeout(_geocodeTimeout);

      if (placemarks.isNotEmpty) {
        final address = _formatPlacemark(placemarks.first);
        if (address.isNotEmpty) {
          await _cacheAddress(location, address);

          final enriched = location.copyWith(address: address);
          // Keep the stored fix in step so the label survives a restart.
          if (_inMemory?.coarseKey == location.coarseKey) {
            _inMemory = enriched;
            await _persist(enriched);
          }
          return enriched;
        }
      }
    } catch (e) {
      // Offline, throttled or no geocoder backend: expected, not an error.
      debugPrint('LocationService: reverse geocoding unavailable ($e)');
    }

    if (location.address.isNotEmpty) return location;

    return location.copyWith(
      address: unknownLabel != null
          ? '$unknownLabel (${location.formattedCoordinates})'
          : location.formattedCoordinates,
    );
  }

  static String _formatPlacemark(Placemark place) {
    // Neighbourhood (if it adds information), then city, then country.
    final neighbourhood = _firstNonEmpty([place.subLocality, place.thoroughfare]);
    final city = _firstNonEmpty([place.locality, place.subAdministrativeArea]);
    final region = _firstNonEmpty([place.administrativeArea]);
    final country = _firstNonEmpty([place.country]);

    final parts = <String>[
      if (neighbourhood != null && neighbourhood != city) neighbourhood,
      if (city != null) city,
      if (city == null && region != null) region,
      if (country != null) country,
    ];

    return parts.join(', ');
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  static Future<LocationData?> _readPersistedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_locationCacheKey);
      if (raw == null) return null;
      return LocationData.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('LocationService: could not read cached location ($e)');
      return null;
    }
  }

  static Future<void> _persist(LocationData location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _locationCacheKey,
        json.encode(location.toJson()),
      );
    } catch (e) {
      debugPrint('LocationService: could not persist location ($e)');
    }
  }

  static Future<String?> _cachedAddressFor(LocationData location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_addressCachePrefix${location.coarseKey}');
    } catch (_) {
      return null;
    }
  }

  static Future<void> _cacheAddress(LocationData location, String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_addressCachePrefix${location.coarseKey}',
        address,
      );
    } catch (_) {
      // Cache misses are harmless.
    }
  }

  // ---------------------------------------------------------------------------
  // Diagnostics
  // ---------------------------------------------------------------------------

  static Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  static Future<LocationPermission> getLocationPermission() =>
      Geolocator.checkPermission();

  @visibleForTesting
  static void resetForTest() {
    _inMemory = null;
    _inFlight = null;
  }
}
