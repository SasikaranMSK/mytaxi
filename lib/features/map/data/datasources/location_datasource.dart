import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/location_entity.dart';

class LocationDataSource {
  // ✅ MapBloc needs this
  Future<LocationEntity?> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null; // ✅ no throw
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      return LocationEntity(lat: pos.latitude, lng: pos.longitude);
    } catch (e) {
      debugPrint("getCurrentLocation error: $e");
      return null;
    }
  }

  // ✅ MapBloc needs this
  Stream<LocationEntity?> streamLocation() {
    try {
      return Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: kIsWeb ? LocationAccuracy.best : LocationAccuracy.bestForNavigation,
          distanceFilter: 2,
        ),
      ).map((pos) => LocationEntity(lat: pos.latitude, lng: pos.longitude));
    } catch (e) {
      // stream error -> return empty stream (no crash)
      debugPrint("streamLocation error: $e");
      return const Stream.empty();
    }
  }
}
