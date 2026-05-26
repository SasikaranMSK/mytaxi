import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meter_model.dart';

class MeterLocalDataSource {
  final SharedPreferences _prefs;
  MeterLocalDataSource(this._prefs);

  static const _keyTrips = 'meter_trips';

  Future<Map<String, MeterModel>> _readMap() async {
    final jsonString = _prefs.getString(_keyTrips);
    if (jsonString == null || jsonString.isEmpty) return {};

    try {
      final raw = jsonDecode(jsonString);
      if (raw is List) {
        // backward compatibility: old list storage
        final map = <String, MeterModel>{};
        for (final item in raw) {
          if (item is Map) {
            final model = MeterModel.fromJson(item.cast<String, dynamic>());
            map[model.tripId] = model;
          }
        }
        return map;
      }

      if (raw is Map) {
        final map = <String, MeterModel>{};
        raw.forEach((key, value) {
          if (value is Map) {
            map[key] = MeterModel.fromJson(value.cast<String, dynamic>());
          }
        });
        return map;
      }

      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeMap(Map<String, MeterModel> map) async {
    final jsonMap = map.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs.setString(_keyTrips, jsonEncode(jsonMap));
  }

  /// ✅ Upsert 1 trip
  Future<void> upsertTrip(MeterModel trip) async {
    final map = await _readMap();

    final existing = map[trip.tripId];
    if (existing == null) {
      map[trip.tripId] = trip;
    } else {
      // merge: keep latest fields (e.g. endTime, fare updates)
      map[trip.tripId] = existing.copyWith(
        distance: trip.distance,
        waitingTime: trip.waitingTime,
        totalFare: trip.totalFare,
        endTime: trip.endTime ?? existing.endTime,
      );
    }

    await _writeMap(map);
  }

  /// ✅ Upsert many trips (remote sync)
  Future<void> upsertTrips(List<MeterModel> trips) async {
    final map = await _readMap();
    for (final trip in trips) {
      final existing = map[trip.tripId];
      if (existing == null) {
        map[trip.tripId] = trip;
      } else {
        map[trip.tripId] = existing.copyWith(
          distance: trip.distance,
          waitingTime: trip.waitingTime,
          totalFare: trip.totalFare,
          endTime: trip.endTime ?? existing.endTime,
        );
      }
    }
    await _writeMap(map);
  }

  Future<List<MeterModel>> getAllTripsModels() async {
    final map = await _readMap();
    final list = map.values.toList();

    // newest first
    list.sort((a, b) => b.startTime.compareTo(a.startTime));
    return list;
  }

  Future<List<MeterModel>> getAllTrips() => getAllTripsModels();

  Future<void> clearTrips() async {
    await _prefs.remove(_keyTrips);
  }
}
