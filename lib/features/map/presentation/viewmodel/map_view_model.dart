import 'package:latlong2/latlong.dart';
import '../bloc/map_state.dart';

class MapViewModel {
  final bool isLoading;
  final String? errorMessage;
  final double? lat;
  final double? lng;

  const MapViewModel({
    required this.isLoading,
    required this.errorMessage,
    required this.lat,
    required this.lng,
  });

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;
  bool get hasLocation => lat != null && lng != null;

  /// Default fallback (Jaffna)
  LatLng get center {
    final safeLat = lat ?? 9.6615;
    final safeLng = lng ?? 80.0255;
    return LatLng(safeLat, safeLng);
  }

  /// Only show overlay when first location is not yet available
  bool get showInitialLoading => isLoading && !hasLocation;

  factory MapViewModel.fromState(MapState state) {
    return MapViewModel(
      isLoading: state.loading,
      errorMessage: state.error,
      lat: state.lat,
      lng: state.lng,
    );
  }
}
