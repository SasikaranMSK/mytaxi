/// Domain entity representing a tariff
class TariffEntity {
  final int tarifId;
  final String tarifName;
  final bool active;
  final double flagFall;
  final double distanceRate;
  final double distanceRateRange;
  final double distanceRate2;
  final double timeRate;
  final double waitingTimeRate;
  final String startTime;
  final String endTime;
  final int fromDay;
  final int toDay;
  final bool publicHolidays;

  const TariffEntity({
    required this.tarifId,
    required this.tarifName,
    required this.active,
    required this.flagFall,
    required this.distanceRate,
    required this.distanceRateRange,
    required this.distanceRate2,
    required this.timeRate,
    required this.waitingTimeRate,
    required this.startTime,
    required this.endTime,
    required this.fromDay,
    required this.toDay,
    required this.publicHolidays,
  });
}
