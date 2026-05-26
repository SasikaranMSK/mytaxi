import '../../domain/entities/meter_entity.dart';
import '../../domain/repositories/meter_repository.dart';
import '../datasources/meter_local_datasource.dart';
import '../datasources/meter_remote_data_source.dart';
import '../mappers/meter_mapper.dart';

class MeterRepositoryImpl implements MeterRepository {
  final MeterLocalDataSource localDataSource;
  final MeterRemoteDataSource? remoteDataSource;

  MeterRepositoryImpl({required this.localDataSource, this.remoteDataSource});

  @override
  Future<void> saveTrip(MeterEntity trip) async {
    final dto = trip.toDto();
    final model = dto.toModel();

    // ✅ save to local database only
    await localDataSource.upsertTrip(model);
  }

  @override
  Future<List<MeterEntity>> getAllTrips() async {
    // ✅ fetch from local database only
    final localTrips = await localDataSource.getAllTrips();
    return localTrips.map((e) => e.toDto().toEntity()).toList();
  }
}
