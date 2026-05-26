import 'package:flutter_test/flutter_test.dart';
import 'package:meter_taxi/features/map/data/mappers/location_history_mapper.dart';
import 'package:meter_taxi/features/map/domain/entities/location_history_entity.dart';

void main() {
  test('Location history mapping round-trip preserves fields', () {
    final entity = LocationHistoryEntity(
      id: 11,
      lat: 25.276987,
      lng: 55.296249,
      timestamp: DateTime.utc(2026, 2, 8, 9, 15),
    );

    final dto = entity.toDto();
    final model = dto.toModel();
    final roundTrip = model.toDto().toEntity();

    expect(roundTrip.id, entity.id);
    expect(roundTrip.lat, entity.lat);
    expect(roundTrip.lng, entity.lng);
    expect(roundTrip.timestamp, entity.timestamp);
  });
}
