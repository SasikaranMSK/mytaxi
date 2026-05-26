import 'package:flutter_test/flutter_test.dart';
import 'package:meter_taxi/features/authentication/data/mappers/auth_mapper.dart';
import 'package:meter_taxi/features/authentication/domain/entities/auth_entity.dart';

void main() {
  test('Auth mapping round-trip preserves fields', () {
    const entity = AuthEntity(
      token: 'token-123',
      username: 'driver1',
      deviceId: 'device-abc',
    );

    final dto = entity.toDto();
    final model = dto.toModel();
    final roundTrip = model.toDto().toEntity();

    expect(roundTrip.token, entity.token);
    expect(roundTrip.username, entity.username);
    expect(roundTrip.deviceId, entity.deviceId);
  });
}
