import 'package:floor/floor.dart';

/// Floor database model for VehicleTypeTariff
@Entity(tableName: 'vehicle_type_tariffs')
class VehicleTypeTariffModel {
  @PrimaryKey(autoGenerate: false)
  final int vehicleTypeTarifId;

  final int vehicleTypeId;
  final int tarifId;
  final bool active;

  VehicleTypeTariffModel({
    required this.vehicleTypeTarifId,
    required this.vehicleTypeId,
    required this.tarifId,
    required this.active,
  });

  // Mapping is handled via DTO mappers to keep entity decoupled.
}
