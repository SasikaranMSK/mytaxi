// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_type_tariff_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleTypeTariffDto _$VehicleTypeTariffDtoFromJson(
        Map<String, dynamic> json) =>
    VehicleTypeTariffDto(
      vehicleTypeTarifId: (json['vehicleTypeTarifId'] as num).toInt(),
      vehicleTypeId: (json['vehicleTypeId'] as num).toInt(),
      tarifId: (json['tarifId'] as num).toInt(),
      active: json['active'] as bool,
      vehicleType: json['vehicleType'],
      tarif: json['tarif'] == null
          ? null
          : TariffDto.fromJson(json['tarif'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VehicleTypeTariffDtoToJson(
        VehicleTypeTariffDto instance) =>
    <String, dynamic>{
      'vehicleTypeTarifId': instance.vehicleTypeTarifId,
      'vehicleTypeId': instance.vehicleTypeId,
      'tarifId': instance.tarifId,
      'active': instance.active,
      'vehicleType': instance.vehicleType,
      'tarif': instance.tarif,
    };
