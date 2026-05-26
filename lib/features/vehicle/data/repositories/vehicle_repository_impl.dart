import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_local_data_source.dart';
import '../datasources/vehicle_remote_data_source.dart';
import '../mappers/vehicle_mapper.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remote;
  final VehicleLocalDataSource local;

  VehicleRepositoryImpl({required this.remote, required this.local});

  @override
  Future<VehicleEntity> fetchAndSaveVehicle({
    required int networkId,
    required String vehicleNo,
  }) async {
    final dto = await remote.getVehicle(networkId: networkId, vehicleNo: vehicleNo);

    final model = dto.toModel();

    await local.saveVehicle(model);
    return model.toDto().toEntity();
  }
}
