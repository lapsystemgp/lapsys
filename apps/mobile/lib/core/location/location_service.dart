import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// A simple latitude/longitude pair.
class LatLng {
  final double lat;
  final double lng;
  const LatLng(this.lat, this.lng);
}

/// Thin wrapper around `geolocator` that handles the permission dance and
/// returns `null` (rather than throwing) whenever a fix can't be obtained, so
/// callers can transparently fall back to a non-distance sort.
class LocationService {
  Future<LatLng?> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 27),
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      // Timeout / transient platform error — treat as "no location".
      return null;
    }
  }
}

final locationServiceProvider = Provider<LocationService>(
  (_) => LocationService(),
);

/// Resolves the user's location once and caches it for the session, so screens
/// can read it without each re-triggering the permission prompt. Resolves to
/// `null` when permission is denied or no fix is available.
final currentLocationProvider = FutureProvider<LatLng?>((ref) {
  return ref.watch(locationServiceProvider).getCurrentLocation();
});

/// Great-circle distance in km, rounded to one decimal — matches the
/// frontend's `haversineKm` exactly so both clients show the same numbers.
double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  double toRad(double d) => d * math.pi / 180.0;
  final dLat = toRad(lat2 - lat1);
  final dLng = toRad(lng2 - lng1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(toRad(lat1)) *
          math.cos(toRad(lat2)) *
          math.pow(math.sin(dLng / 2), 2);
  final km = r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return (km * 10).round() / 10;
}
