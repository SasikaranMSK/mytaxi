import '../../domain/entities/tariff_entity.dart';
import '../../domain/entities/vehicle_type_tariff_entity.dart';
import '../dto/tariff_dto.dart';
import '../dto/vehicle_type_tariff_dto.dart';
import '../models/tariff_model.dart';
import '../models/vehicle_type_tariff_model.dart';

extension TariffEntityMapper on TariffEntity {
  TariffDto toDto() => TariffDto(
        tarifId: tarifId,
        tarifName: tarifName,
        description: null,
        active: active,
        defaultTariff: false,
        publicHolidays: publicHolidays,
        bankHolidays: false,
        distanceUnit: 'km',
        dropInterval: 0,
        flagFall: flagFall,
        flagDistance: 0,
        extrasIncrement: 0,
        distanceRate: distanceRate,
        distanceRateRange: distanceRateRange,
        distanceRate2: distanceRate2,
        distanceRate2Range: 0,
        speedThreshold: 0,
        timeRate: timeRate,
        journeyTimeRate: 0,
        waitingTimeRate: waitingTimeRate,
        timeRateSpeedThreshold: 0,
        returnToBoundaryDistanceDate: 0,
        returnToBoundaryMinimumDistance: 0,
        startTime: startTime,
        endTime: endTime,
        fromDay: fromDay,
        toDay: toDay,
        secretKey: '',
      );
}

extension TariffDtoMapper on TariffDto {
  TariffEntity toEntity() => TariffEntity(
        tarifId: tarifId,
        tarifName: tarifName,
        active: active,
        flagFall: flagFall,
        distanceRate: distanceRate,
        distanceRateRange: distanceRateRange,
        distanceRate2: distanceRate2,
        timeRate: timeRate,
        waitingTimeRate: waitingTimeRate,
        startTime: startTime,
        endTime: endTime,
        fromDay: fromDay,
        toDay: toDay,
        publicHolidays: publicHolidays,
      );

  TariffModel toModel() => TariffModel(
        tarifId: tarifId,
        tarifName: tarifName,
        description: description,
        active: active,
        defaultTariff: defaultTariff,
        publicHolidays: publicHolidays,
        bankHolidays: bankHolidays,
        distanceUnit: distanceUnit,
        dropInterval: dropInterval,
        flagFall: flagFall,
        flagDistance: flagDistance,
        extrasIncrement: extrasIncrement,
        distanceRate: distanceRate,
        distanceRateRange: distanceRateRange,
        distanceRate2: distanceRate2,
        distanceRate2Range: distanceRate2Range,
        speedThreshold: speedThreshold,
        timeRate: timeRate,
        journeyTimeRate: journeyTimeRate,
        waitingTimeRate: waitingTimeRate,
        timeRateSpeedThreshold: timeRateSpeedThreshold,
        returnToBoundaryDistanceDate: returnToBoundaryDistanceDate,
        returnToBoundaryMinimumDistance: returnToBoundaryMinimumDistance,
        startTime: startTime,
        endTime: endTime,
        fromDay: fromDay,
        toDay: toDay,
        secretKey: secretKey,
      );
}

extension TariffModelMapper on TariffModel {
  TariffDto toDto() => TariffDto(
        tarifId: tarifId,
        tarifName: tarifName,
        description: description,
        active: active,
        defaultTariff: defaultTariff,
        publicHolidays: publicHolidays,
        bankHolidays: bankHolidays,
        distanceUnit: distanceUnit,
        dropInterval: dropInterval,
        flagFall: flagFall,
        flagDistance: flagDistance,
        extrasIncrement: extrasIncrement,
        distanceRate: distanceRate,
        distanceRateRange: distanceRateRange,
        distanceRate2: distanceRate2,
        distanceRate2Range: distanceRate2Range,
        speedThreshold: speedThreshold,
        timeRate: timeRate,
        journeyTimeRate: journeyTimeRate,
        waitingTimeRate: waitingTimeRate,
        timeRateSpeedThreshold: timeRateSpeedThreshold,
        returnToBoundaryDistanceDate: returnToBoundaryDistanceDate,
        returnToBoundaryMinimumDistance: returnToBoundaryMinimumDistance,
        startTime: startTime,
        endTime: endTime,
        fromDay: fromDay,
        toDay: toDay,
        secretKey: secretKey,
      );

  TariffEntity toEntity() => toDto().toEntity();
}

extension VehicleTypeTariffEntityMapper on VehicleTypeTariffEntity {
  VehicleTypeTariffDto toDto() => VehicleTypeTariffDto(
        vehicleTypeTarifId: vehicleTypeTarifId,
        vehicleTypeId: vehicleTypeId,
        tarifId: tarifId,
        active: active,
        tarif: tariff?.toDto(),
      );
}

extension VehicleTypeTariffDtoMapper on VehicleTypeTariffDto {
  VehicleTypeTariffEntity toEntity() => VehicleTypeTariffEntity(
        vehicleTypeTarifId: vehicleTypeTarifId,
        vehicleTypeId: vehicleTypeId,
        tarifId: tarifId,
        active: active,
        tariff: tarif?.toEntity(),
      );

  VehicleTypeTariffModel toModel() => VehicleTypeTariffModel(
        vehicleTypeTarifId: vehicleTypeTarifId,
        vehicleTypeId: vehicleTypeId,
        tarifId: tarifId,
        active: active,
      );
}

extension VehicleTypeTariffModelMapper on VehicleTypeTariffModel {
  VehicleTypeTariffDto toDto({TariffDto? tariff}) => VehicleTypeTariffDto(
        vehicleTypeTarifId: vehicleTypeTarifId,
        vehicleTypeId: vehicleTypeId,
        tarifId: tarifId,
        active: active,
        tarif: tariff,
      );

  VehicleTypeTariffEntity toEntity({TariffDto? tariff}) =>
      toDto(tariff: tariff).toEntity();
}
