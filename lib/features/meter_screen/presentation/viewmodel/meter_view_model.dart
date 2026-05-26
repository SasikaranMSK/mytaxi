import '../../domain/entities/meter_entity.dart';
import '../../../tariff/domain/entities/tariff_entity.dart';
import '../bloc/meter_state.dart';

class MeterViewModel {
  final MeterState state;
  final TariffEntity tariff;

  const MeterViewModel({
    required this.state,
    required this.tariff,
  });

  // ------------ Raw passthrough ------------
  bool get isRunning => state.isRunning;
  bool get isWaiting => state.isWaiting;
  bool get isPaused => state.isPaused;

  DateTime? get startTime => state.startTime;
  DateTime? get endTime => state.endTime;

  double get distanceKm => state.distance;
  int get waitingSeconds => state.waitingTime;
  double get totalFare => state.totalFare;

  // ------------ UI text helpers ------------
  String get distanceText => '${distanceKm.toStringAsFixed(2)} km';

  String get waitingText => '${(waitingSeconds ~/ 60)} min';

  String get totalFareText => totalFare.toStringAsFixed(2);

  /// If running -> now - startTime, else endTime - startTime
  String get durationText {
    final s = startTime;
    if (s == null) return '--:--:--';

    final e = (isRunning) ? DateTime.now() : endTime;
    if (e == null) return '--:--:--';

    final d = e.difference(s);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  /// Optional: for saving history quickly (if you need later)
  MeterEntity toTripEntity({
    required String tripId,
    required int tariffId,
    required int vehicleId,
    required DateTime endTime,
  }) {
    return MeterEntity(
      tripId: tripId,
      distance: distanceKm,
      waitingTime: waitingSeconds,
      totalFare: totalFare,
      startTime: startTime ?? DateTime.now(),
      endTime: endTime,
      tariffId: tariffId,
      vehicleId: vehicleId,
    );
  }
}
