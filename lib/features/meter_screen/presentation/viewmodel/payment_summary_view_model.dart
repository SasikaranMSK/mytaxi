import '../../../tariff/domain/entities/tariff_entity.dart';
import '../pages/payment_summary_page.dart';

class PaymentSummaryViewModel {
  final PaymentSummaryArgs args;

  const PaymentSummaryViewModel(this.args);

  double get totalFare => args.totalFare;
  String get totalFareText => totalFare.toStringAsFixed(2);

  String get distanceText => '${args.distanceKm.toStringAsFixed(2)} km';

  String get waitingText {
    final minutes = args.waitingSeconds ~/ 60;
    final seconds = args.waitingSeconds % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(minutes)}:${two(seconds)}';
  }

  String get durationText {
    final duration = args.endTime.difference(args.startTime);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(duration.inHours)}:${two(duration.inMinutes.remainder(60))}:${two(duration.inSeconds.remainder(60))}';
  }

  String get startTimeText {
    return '${args.startTime.hour.toString().padLeft(2, '0')}:${args.startTime.minute.toString().padLeft(2, '0')} (${_formatDate(args.startTime)})';
  }

  String get endTimeText {
    return '${args.endTime.hour.toString().padLeft(2, '0')}:${args.endTime.minute.toString().padLeft(2, '0')} (${_formatDate(args.endTime)})';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  FareBreakdownViewModel get breakdown => FareBreakdownViewModel(
    distance: args.distanceKm,
    waitingSeconds: args.waitingSeconds,
    tariff: args.tariff,
  );
}

class FareBreakdownViewModel {
  static const double _minMovementThreshold = 0.1;

  final double distance;
  final int waitingSeconds;
  final TariffEntity tariff;

  FareBreakdownViewModel({
    required this.distance,
    required this.waitingSeconds,
    required this.tariff,
  });

  double get _safeDistance => distance < 0 ? 0.0 : distance;
  int get _safeWaitingSeconds => waitingSeconds < 0 ? 0 : waitingSeconds;

  // cents -> dollars
  double get flagFall => _roundToDime(tariff.flagFall / 100.0);
  double get _rate1 => tariff.distanceRate / 100.0;
  double get _rate2 => tariff.distanceRate2 / 100.0;
  double get _waitRatePerMin => tariff.timeRate / 100.0;

  /// Detect if vehicle was moving during the trip
  bool get _wasVehicleMoving => _safeDistance > _minMovementThreshold;

  /// Round to nearest dime (10 cents)
  double _roundToDime(double value) {
    return (value * 10).round() / 10.0;
  }

  /// Distance charges - ONLY if vehicle was moving
  double get distanceFareTier1 {
    if (!_wasVehicleMoving) return 0;
    if (_safeDistance <= tariff.distanceRateRange) {
      return _roundToDime(_safeDistance * _rate1);
    }
    return _roundToDime(tariff.distanceRateRange * _rate1);
  }

  /// Distance charges tier 2 - ONLY if vehicle was moving AND distance exceeded range
  double get distanceFareTier2 {
    if (!_wasVehicleMoving) return 0;
    if (_safeDistance <= tariff.distanceRateRange) return 0;
    final remaining = _safeDistance - tariff.distanceRateRange;
    return _roundToDime(remaining * _rate2);
  }

  /// Waiting charges - ONLY if vehicle was stationary for more than 1 minute
  double get waitingFare {
    if (_wasVehicleMoving) return 0; // Don't charge waiting if vehicle moved
    if (_safeWaitingSeconds <= 60) return 0; // Only charge after 1 minute
    final waitingMinutes = _safeWaitingSeconds / 60.0;
    return _roundToDime(waitingMinutes * _waitRatePerMin);
  }

  /// Total fare with 10-cent rounding
  double get total {
    final subtotal =
        flagFall + distanceFareTier1 + distanceFareTier2 + waitingFare;
    return _roundToDime(subtotal);
  }

  String money(double v) => v.toStringAsFixed(2);

  String get flagFallText => money(flagFall);
  String get tier1Text => money(distanceFareTier1);
  String get tier2Text => money(distanceFareTier2);
  String get waitingText => money(waitingFare);
  String get totalText => money(total);

  /// Get breakdown summary for debugging/info
  String get breakdownSummary {
    if (_wasVehicleMoving) {
      return 'Distance: ${distance.toStringAsFixed(2)} km | Duration: ${(waitingSeconds ~/ 60)} min';
    } else {
      return 'Stationary: ${(waitingSeconds ~/ 60)} min (waiting time charges only)';
    }
  }
}
