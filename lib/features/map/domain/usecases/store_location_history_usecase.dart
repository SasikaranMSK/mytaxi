import '../entities/location_history_entity.dart';
import '../repositories/location_history_repository.dart';

/// Use case for storing location history and managing cleanup
class StoreLocationHistoryUseCase {
  final LocationHistoryRepository _repository;
  static const int _fiveMinutesInMilliseconds = 5 * 60 * 1000;

  StoreLocationHistoryUseCase(this._repository);

  /// Store a new location point and cleanup old data (older than 5 minutes)
  Future<void> call({required double lat, required double lng}) async {
    // Store the new location
    final location = LocationHistoryEntity(
      lat: lat,
      lng: lng,
      timestamp: DateTime.now(),
    );
    await _repository.storeLocation(location);

    // Cleanup: delete data older than 5 minutes
    final cutoffTime = DateTime.now().subtract(
      const Duration(milliseconds: _fiveMinutesInMilliseconds),
    );
    await _repository.deleteOlderThan(cutoffTime);
  }

  /// Get all location history from the last 5 minutes
  Future<List<LocationHistoryEntity>> getRecentHistory() async {
    final cutoffTime = DateTime.now().subtract(
      const Duration(milliseconds: _fiveMinutesInMilliseconds),
    );
    return await _repository.getHistorySince(cutoffTime);
  }

  /// Get all location history
  Future<List<LocationHistoryEntity>> getAllHistory() {
    return _repository.getAllHistory();
  }

  /// Get count of stored locations
  Future<int> getCount() {
    return _repository.getCount();
  }

  /// Clear all location history
  Future<void> clearAll() {
    return _repository.clearAll();
  }
}
