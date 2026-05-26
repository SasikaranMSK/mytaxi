import 'package:equatable/equatable.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => [];
}

class MapStarted extends MapEvent {}

class MapStopped extends MapEvent {}

class MapLocationUpdated extends MapEvent {
  final double lat;
  final double lng;

  const MapLocationUpdated({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];
}
