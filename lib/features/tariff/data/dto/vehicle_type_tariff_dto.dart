import 'package:json_annotation/json_annotation.dart';
import 'tariff_dto.dart';
import '../models/vehicle_type_tariff_model.dart';

part 'vehicle_type_tariff_dto.g.dart';

/// Data Transfer Object for VehicleTypeTariff from API
@JsonSerializable()
class VehicleTypeTariffDto {
  final int vehicleTypeTarifId;
  final int vehicleTypeId;
  final int tarifId;
  final bool active;
  final dynamic vehicleType;
  final TariffDto? tarif;

  VehicleTypeTariffDto({
    required this.vehicleTypeTarifId,
    required this.vehicleTypeId,
    required this.tarifId,
    required this.active,
    this.vehicleType,
    this.tarif,
  });

  /// From JSON
  factory VehicleTypeTariffDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleTypeTariffDtoFromJson(json);

  /// To JSON
  Map<String, dynamic> toJson() => _$VehicleTypeTariffDtoToJson(this);

  /// Convert DTO to Model
  VehicleTypeTariffModel toModel() {
    return VehicleTypeTariffModel(
      vehicleTypeTarifId: vehicleTypeTarifId,
      vehicleTypeId: vehicleTypeId,
      tarifId: tarifId,
      active: active,
    );
  }
}
