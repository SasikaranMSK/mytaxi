import 'package:floor/floor.dart';

/// Floor database model for Tariff
@Entity(tableName: 'tariffs')
class TariffModel {
  @PrimaryKey(autoGenerate: false)
  final int tarifId;

  final String tarifName;
  final String? description;
  final bool active;
  final bool defaultTariff;
  final bool publicHolidays;
  final bool bankHolidays;
  final String distanceUnit;
  final int dropInterval;
  final double flagFall;
  final double flagDistance;
  final double extrasIncrement;
  final double distanceRate;
  final double distanceRateRange;
  final double distanceRate2;
  final double distanceRate2Range;
  final double speedThreshold;
  final double timeRate;
  final double journeyTimeRate;
  final double waitingTimeRate;
  final double timeRateSpeedThreshold;
  final double returnToBoundaryDistanceDate;
  final double returnToBoundaryMinimumDistance;
  final String startTime;
  final String endTime;
  final int fromDay;
  final int toDay;
  final String secretKey;

  TariffModel({
    required this.tarifId,
    required this.tarifName,
    this.description,
    required this.active,
    required this.defaultTariff,
    required this.publicHolidays,
    required this.bankHolidays,
    required this.distanceUnit,
    required this.dropInterval,
    required this.flagFall,
    required this.flagDistance,
    required this.extrasIncrement,
    required this.distanceRate,
    required this.distanceRateRange,
    required this.distanceRate2,
    required this.distanceRate2Range,
    required this.speedThreshold,
    required this.timeRate,
    required this.journeyTimeRate,
    required this.waitingTimeRate,
    required this.timeRateSpeedThreshold,
    required this.returnToBoundaryDistanceDate,
    required this.returnToBoundaryMinimumDistance,
    required this.startTime,
    required this.endTime,
    required this.fromDay,
    required this.toDay,
    required this.secretKey,
  });

  // Mapping is handled via DTO mappers to keep entity decoupled.
}
