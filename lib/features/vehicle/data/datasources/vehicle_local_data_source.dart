import 'dart:convert';
import '../../../../core/storage/vehicle_storage.dart';
import '../dto/vehicle_dto.dart';
import '../mappers/vehicle_mapper.dart';
import '../models/vehicle_model.dart';

abstract class VehicleLocalDataSource {
  Future<void> saveVehicle(VehicleModel model);
  Future<VehicleDto?> getVehicle();
  Future<void> clear();
}

class VehicleLocalDataSourceImpl implements VehicleLocalDataSource {
  final VehicleStorage storage;

  VehicleLocalDataSourceImpl({required this.storage});

  @override
  Future<void> saveVehicle(VehicleModel model) async {
    final jsonStr = jsonEncode(model.toJson());
    await storage.saveVehicleJson(jsonStr);
  }

  @override
  Future<VehicleDto?> getVehicle() async {
    final jsonStr = await storage.getVehicleJson();
    if (jsonStr == null || jsonStr.isEmpty) return null;
    final model =
        VehicleModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    return model.toDto();
  }

  @override
  Future<void> clear() => storage.clearVehicle();
}
