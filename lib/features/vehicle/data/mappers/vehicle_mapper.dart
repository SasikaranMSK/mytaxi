import '../../domain/entities/vehicle_entity.dart';
import '../dto/vehicle_dto.dart';
import '../models/vehicle_model.dart';

extension VehicleEntityMapper on VehicleEntity {
  VehicleDto toDto() => VehicleDto(
        id: id,
        vehicleNo: vehicleNo,
        vehicleTypeId: vehicleTypeId,
        devicePhoneNumber: devicePhoneNumber,
        active: active,
      );
}

extension VehicleDtoMapper on VehicleDto {
  VehicleEntity toEntity() => VehicleEntity(
        id: id,
        vehicleNo: vehicleNo,
        vehicleTypeId: vehicleTypeId,
        devicePhoneNumber: devicePhoneNumber,
        active: active,
      );

  VehicleModel toModel() => VehicleModel(
        id: id,
        vehicleNo: vehicleNo,
        vehicleTypeId: vehicleTypeId,
        devicePhoneNumber: devicePhoneNumber,
        active: active,
      );
}

extension VehicleModelMapper on VehicleModel {
  VehicleDto toDto() => VehicleDto(
        id: id,
        vehicleNo: vehicleNo,
        vehicleTypeId: vehicleTypeId,
        devicePhoneNumber: devicePhoneNumber,
        active: active,
      );

  VehicleEntity toEntity() => toDto().toEntity();
}
