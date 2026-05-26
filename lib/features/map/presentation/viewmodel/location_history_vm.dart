import '../../domain/entities/location_history_entity.dart';
import 'location_point_vm.dart';

class LocationHistoryVm {
  final List<LocationPointVm> points;

  const LocationHistoryVm({required this.points});

  bool get hasPoints => points.isNotEmpty;
  LocationPointVm? get latest => points.isEmpty ? null : points.last;

  factory LocationHistoryVm.fromEntities(List<LocationHistoryEntity> history) {
    return LocationHistoryVm(
      points: history
          .map(
            (h) => LocationPointVm(
          lat: h.lat,
          lng: h.lng,
          timestamp: h.timestamp,
        ),
      )
          .toList(),
    );
  }
}
