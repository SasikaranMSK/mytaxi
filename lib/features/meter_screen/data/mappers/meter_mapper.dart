import '../../domain/entities/meter_entity.dart';
import '../dto/meter_dto.dart';
import '../models/meter_model.dart';

extension MeterEntityMapper on MeterEntity {
  MeterDto toDto() => MeterDto(
        tripId: tripId,
        distance: distance,
        waitingTime: waitingTime,
        totalFare: totalFare,
        startTime: startTime.toIso8601String(),
        endTime: endTime?.toIso8601String(),
        tariffId: tariffId,
        vehicleId: vehicleId,
      );
}

extension MeterDtoMapper on MeterDto {
  MeterEntity toEntity() => MeterEntity(
        tripId: tripId,
        distance: distance,
        waitingTime: waitingTime,
        totalFare: totalFare,
        startTime: DateTime.parse(startTime),
        endTime: endTime != null ? DateTime.parse(endTime!) : null,
        tariffId: tariffId,
        vehicleId: vehicleId,
      );

  MeterModel toModel() => MeterModel(
        tripId: tripId,
        distance: distance,
        waitingTime: waitingTime,
        totalFare: totalFare,
        startTime: DateTime.parse(startTime),
        endTime: endTime != null ? DateTime.parse(endTime!) : null,
        tariffId: tariffId,
        vehicleId: vehicleId,
      );
}

extension MeterModelMapper on MeterModel {
  MeterDto toDto() => MeterDto(
        tripId: tripId,
        distance: distance,
        waitingTime: waitingTime,
        totalFare: totalFare,
        startTime: startTime.toIso8601String(),
        endTime: endTime?.toIso8601String(),
        tariffId: tariffId,
        vehicleId: vehicleId,
      );

  MeterEntity toEntity() => toDto().toEntity();
}
