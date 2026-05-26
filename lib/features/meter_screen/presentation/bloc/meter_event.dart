import 'package:equatable/equatable.dart';

abstract class MeterEvent extends Equatable {
  const MeterEvent();
  @override
  List<Object?> get props => [];
}

class StartMeterEvent extends MeterEvent {}

class StopMeterEvent extends MeterEvent {}

class UpdateDistanceEvent extends MeterEvent {
  final double distanceKm;
  const UpdateDistanceEvent(this.distanceKm);

  @override
  List<Object?> get props => [distanceKm];
}

/// ✅ Pause toggle
class TogglePauseEvent extends MeterEvent {}

/// ✅ Set Waiting Explicitly (Auto Wait)
class SetWaitingEvent extends MeterEvent {
  final bool isWaiting;
  const SetWaitingEvent(this.isWaiting);
  @override
  List<Object?> get props => [isWaiting];
}

class MeterTickEvent extends MeterEvent {}

class ResetMeterEvent extends MeterEvent {}

/// Event to restore state from shared preferences
class RestoreStateEvent extends MeterEvent {}

/// Event to update state from foreground service
class UpdateFromForegroundEvent extends MeterEvent {
  final double distance;
  final int waitingTime;
  final bool isWaiting;

  const UpdateFromForegroundEvent({
    required this.distance,
    required this.waitingTime,
    required this.isWaiting,
  });

  @override
  List<Object?> get props => [distance, waitingTime, isWaiting];
}
