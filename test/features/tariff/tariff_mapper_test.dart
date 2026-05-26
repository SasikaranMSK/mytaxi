import 'package:flutter_test/flutter_test.dart';
import 'package:meter_taxi/features/tariff/data/mappers/tariff_mapper.dart';
import 'package:meter_taxi/features/tariff/domain/entities/tariff_entity.dart';
import 'package:meter_taxi/features/tariff/domain/entities/vehicle_type_tariff_entity.dart';

void main() {
  test('Tariff mapping round-trip preserves entity fields', () {
    const entity = TariffEntity(
      tarifId: 1,
      tarifName: 'Standard',
      active: true,
      flagFall: 4.5,
      distanceRate: 1.2,
      distanceRateRange: 10,
      distanceRate2: 1.0,
      timeRate: 0.8,
      waitingTimeRate: 0.5,
      startTime: '06:00',
      endTime: '22:00',
      fromDay: 1,
      toDay: 5,
      publicHolidays: false,
    );

    final dto = entity.toDto();
    final model = dto.toModel();
    final roundTrip = model.toDto().toEntity();

    expect(roundTrip.tarifId, entity.tarifId);
    expect(roundTrip.tarifName, entity.tarifName);
    expect(roundTrip.active, entity.active);
    expect(roundTrip.flagFall, entity.flagFall);
    expect(roundTrip.distanceRate, entity.distanceRate);
    expect(roundTrip.distanceRateRange, entity.distanceRateRange);
    expect(roundTrip.distanceRate2, entity.distanceRate2);
    expect(roundTrip.timeRate, entity.timeRate);
    expect(roundTrip.waitingTimeRate, entity.waitingTimeRate);
    expect(roundTrip.startTime, entity.startTime);
    expect(roundTrip.endTime, entity.endTime);
    expect(roundTrip.fromDay, entity.fromDay);
    expect(roundTrip.toDay, entity.toDay);
    expect(roundTrip.publicHolidays, entity.publicHolidays);
  });

  test('VehicleTypeTariff mapping keeps nested tariff', () {
    const tariff = TariffEntity(
      tarifId: 2,
      tarifName: 'Night',
      active: true,
      flagFall: 6.0,
      distanceRate: 1.5,
      distanceRateRange: 12,
      distanceRate2: 1.2,
      timeRate: 1.0,
      waitingTimeRate: 0.6,
      startTime: '22:00',
      endTime: '06:00',
      fromDay: 1,
      toDay: 7,
      publicHolidays: true,
    );

    const entity = VehicleTypeTariffEntity(
      vehicleTypeTarifId: 10,
      vehicleTypeId: 3,
      tarifId: 2,
      active: true,
      tariff: tariff,
    );

    final dto = entity.toDto();
    final roundTrip = dto.toEntity();

    expect(roundTrip.vehicleTypeTarifId, entity.vehicleTypeTarifId);
    expect(roundTrip.vehicleTypeId, entity.vehicleTypeId);
    expect(roundTrip.tarifId, entity.tarifId);
    expect(roundTrip.active, entity.active);
    expect(roundTrip.tariff?.tarifName, entity.tariff?.tarifName);
  });
}
