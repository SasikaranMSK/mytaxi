import 'package:floor/floor.dart';
import '../models/meter_trip_model.dart';

@dao
abstract class MeterTripDao {
  @Query('SELECT * FROM meter_trips ORDER BY startTime DESC')
  Future<List<MeterTripModel>> getAllTrips();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTrip(MeterTripModel trip);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTrips(List<MeterTripModel> trips);

  @Query('DELETE FROM meter_trips')
  Future<void> clear();
}
