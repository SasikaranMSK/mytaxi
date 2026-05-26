import 'tariff_entity.dart';

/// Domain entity representing a vehicle type tariff
class VehicleTypeTariffEntity {
  final int vehicleTypeTarifId;
  final int vehicleTypeId;
  final int tarifId;
  final bool active;
  final TariffEntity? tariff;

  const VehicleTypeTariffEntity({
    required this.vehicleTypeTarifId,
    required this.vehicleTypeId,
    required this.tarifId,
    required this.active,
    this.tariff,
  });
}
