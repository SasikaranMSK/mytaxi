import 'package:flutter_test/flutter_test.dart';
import 'package:meter_taxi/features/vehicle/data/mappers/vehicle_mapper.dart';
import 'package:meter_taxi/features/vehicle/domain/entities/vehicle_entity.dart';

void main() {
  test('Vehicle mapping round-trip preserves fields', () {
    const entity = VehicleEntity(
      id: 42,
      vehicleNo: 'TX-2042',
      vehicleTypeId: 3,
      devicePhoneNumber: '+15551234567',
      active: true,
    );

    final dto = entity.toDto();
    final model = dto.toModel();
    final roundTrip = model.toDto().toEntity();

    expect(roundTrip.id, entity.id);
    expect(roundTrip.vehicleNo, entity.vehicleNo);
    expect(roundTrip.vehicleTypeId, entity.vehicleTypeId);
    expect(roundTrip.devicePhoneNumber, entity.devicePhoneNumber);
    expect(roundTrip.active, entity.active);
  });
}
