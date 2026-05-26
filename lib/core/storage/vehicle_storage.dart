import 'package:shared_preferences/shared_preferences.dart';

class VehicleStorage {
  static const _vehicleKey = 'vehicle_json';

  final SharedPreferences _prefs;

  VehicleStorage(SharedPreferences prefs) : _prefs = prefs;

  Future<void> saveVehicleJson(String json) async {
    await _prefs.setString(_vehicleKey, json);
  }

  Future<String?> getVehicleJson() async {
    return _prefs.getString(_vehicleKey);
  }

  Future<void> clearVehicle() async {
    await _prefs.remove(_vehicleKey);
  }
}
