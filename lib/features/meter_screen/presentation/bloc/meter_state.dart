import 'package:equatable/equatable.dart';

class MeterState extends Equatable {
  final bool isRunning;
  final bool isWaiting;
  final bool isPaused;

  final DateTime? startTime;
  final DateTime? endTime;

  final double distance; // km
  final double totalFare;

  final int waitingTime; // cumulative charged waiting seconds

  /// Internal counter used to force rebuilds for live-updating UI (e.g. timer)
  final int tick;

  const MeterState({
    required this.isRunning,
    required this.isWaiting,
    required this.isPaused,
    this.startTime,
    this.endTime,
    required this.distance,
    required this.totalFare,
    required this.waitingTime,
    required this.tick,
  });

  factory MeterState.initial() {
    return const MeterState(
      isRunning: false,
      isWaiting: false,
      isPaused: false,
      distance: 0,
      totalFare: 0,
      waitingTime: 0,
      tick: 0,
    );
  }

  MeterState copyWith({
    bool? isRunning,
    bool? isWaiting,
    bool? isPaused,
    DateTime? startTime,
    DateTime? endTime,
    double? distance,
    double? totalFare,
    int? waitingTime,
    int? tick,
  }) {
    return MeterState(
      isRunning: isRunning ?? this.isRunning,
      isWaiting: isWaiting ?? this.isWaiting,
      isPaused: isPaused ?? this.isPaused,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distance: distance ?? this.distance,
      totalFare: totalFare ?? this.totalFare,
      waitingTime: waitingTime ?? this.waitingTime,
      tick: tick ?? this.tick,
    );
  }

  @override
  List<Object?> get props =>
      [isRunning, isWaiting, isPaused, startTime, endTime, distance, totalFare, waitingTime, tick];
}
