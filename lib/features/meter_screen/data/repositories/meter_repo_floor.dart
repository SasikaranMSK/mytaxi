import '../../domain/entities/meter_entity.dart';
import '../../domain/repositories/meter_repository.dart';
import '../dao/meter_trip_dao.dart';
import '../models/meter_trip_model.dart';

class MeterRepositoryFloor implements MeterRepository {
  final MeterTripDao dao;
  MeterRepositoryFloor({required this.dao});

  @override
  Future<void> saveTrip(MeterEntity trip) async {
    final model = MeterTripModel(
      tripId: trip.tripId,
      distance: trip.distance,
      waitingTime: trip.waitingTime,
      totalFare: trip.totalFare,
      startTime: trip.startTime.millisecondsSinceEpoch,
      endTime: trip.endTime?.millisecondsSinceEpoch,
      tariffId: trip.tariffId,
      vehicleId: trip.vehicleId,
    );
    await dao.insertTrip(model);
  }

  @override
  Future<List<MeterEntity>> getAllTrips() async {
    final models = await dao.getAllTrips();
    return models
        .map(
          (m) => MeterEntity(
            tripId: m.tripId,
            distance: m.distance,
            waitingTime: m.waitingTime,
            totalFare: m.totalFare,
            startTime: DateTime.fromMillisecondsSinceEpoch(m.startTime),
            endTime: m.endTime != null
                ? DateTime.fromMillisecondsSinceEpoch(m.endTime!)
                : null,
            tariffId: m.tariffId,
            vehicleId: m.vehicleId,
          ),
        )
        .toList();
  }
}
