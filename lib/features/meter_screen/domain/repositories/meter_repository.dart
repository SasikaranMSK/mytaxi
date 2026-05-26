import '../entities/meter_entity.dart';

abstract class MeterRepository {
  Future<void> saveTrip(MeterEntity trip);
  Future<List<MeterEntity>> getAllTrips();
}
