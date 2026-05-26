import 'package:equatable/equatable.dart';

class MapState extends Equatable {
  final bool loading;
  final String? error;
  final double? lat;
  final double? lng;

  const MapState({
    required this.loading,
    this.error,
    this.lat,
    this.lng,
  });

  factory MapState.initial() => const MapState(loading: true);

  MapState copyWith({
    bool? loading,
    String? error,
    double? lat,
    double? lng,
  }) {
    return MapState(
      loading: loading ?? this.loading,
      error: error,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  List<Object?> get props => [loading, error, lat, lng];
}
