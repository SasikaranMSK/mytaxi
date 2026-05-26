class VehicleWebStorage {
  static final Map<String, String> _mem = {};

  static const _vehicleKey = 'vehicle_json';

  Future<void> saveVehicleJson(String json) async {
    _mem[_vehicleKey] = json;
  }

  Future<String?> getVehicleJson() async {
    return _mem[_vehicleKey];
  }

  Future<void> clearVehicle() async {
    _mem.remove(_vehicleKey);
  }
}
