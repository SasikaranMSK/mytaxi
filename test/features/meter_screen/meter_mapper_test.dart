import 'package:flutter_test/flutter_test.dart';
import 'package:meter_taxi/features/meter_screen/data/mappers/meter_mapper.dart';
import 'package:meter_taxi/features/meter_screen/domain/entities/meter_entity.dart';

void main() {
  test('Meter mapping round-trip preserves fields', () {
    final start = DateTime.utc(2026, 2, 8, 10, 30);
    final end = DateTime.utc(2026, 2, 8, 10, 45);
    final entity = MeterEntity(
      tripId: 'trip-1',
      distance: 12.5,
      waitingTime: 120,
      totalFare: 33.75,
      startTime: start,
      endTime: end,
      tariffId: 3,
      vehicleId: 7,
    );

    final dto = entity.toDto();
    final model = dto.toModel();
    final roundTrip = model.toDto().toEntity();

    expect(roundTrip.tripId, entity.tripId);
    expect(roundTrip.distance, entity.distance);
    expect(roundTrip.waitingTime, entity.waitingTime);
    expect(roundTrip.totalFare, entity.totalFare);
    expect(roundTrip.startTime, entity.startTime);
    expect(roundTrip.endTime, entity.endTime);
    expect(roundTrip.tariffId, entity.tariffId);
    expect(roundTrip.vehicleId, entity.vehicleId);
  });
}
