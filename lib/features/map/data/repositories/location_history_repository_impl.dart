import '../../domain/entities/location_history_entity.dart';
import '../../domain/repositories/location_history_repository.dart';
import '../datasources/location_history_datasource.dart';
import '../mappers/location_history_mapper.dart';

/// Implementation of location history repository
class LocationHistoryRepositoryImpl implements LocationHistoryRepository {
  final LocationHistoryDataSource _dataSource;

  LocationHistoryRepositoryImpl(this._dataSource);

  @override
  Future<void> storeLocation(LocationHistoryEntity location) {
    final model = location.toDto().toModel();
    return _dataSource.storeLocation(model);
  }

  @override
  Future<List<LocationHistoryEntity>> getAllHistory() async {
    final models = await _dataSource.getAllHistory();
    return models.map((m) => m.toDto().toEntity()).toList();
  }

  @override
  Future<List<LocationHistoryEntity>> getHistorySince(DateTime timestamp) async {
    final models = await _dataSource.getHistorySince(timestamp);
    return models.map((m) => m.toDto().toEntity()).toList();
  }

  @override
  Future<void> deleteOlderThan(DateTime timestamp) {
    return _dataSource.deleteOlderThan(timestamp);
  }

  @override
  Future<void> clearAll() {
    return _dataSource.clearAll();
  }

  @override
  Future<int> getCount() {
    return _dataSource.getCount();
  }
}
