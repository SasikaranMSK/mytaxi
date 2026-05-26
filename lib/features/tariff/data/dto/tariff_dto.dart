import 'package:json_annotation/json_annotation.dart';
import '../models/tariff_model.dart';

part 'tariff_dto.g.dart';

/// Data Transfer Object for Tariff from API
@JsonSerializable()
class TariffDto {
  final int tarifId;
  final String tarifName;
  final String? description;
  final bool active;
  @JsonKey(name: 'default')
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

  TariffDto({
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

  /// From JSON
  factory TariffDto.fromJson(Map<String, dynamic> json) =>
      _$TariffDtoFromJson(json);

  /// To JSON
  Map<String, dynamic> toJson() => _$TariffDtoToJson(this);

  /// Convert DTO to Model
  TariffModel toModel() {
    return TariffModel(
      tarifId: tarifId,
      tarifName: tarifName,
      description: description,
      active: active,
      defaultTariff: defaultTariff,
      publicHolidays: publicHolidays,
      bankHolidays: bankHolidays,
      distanceUnit: distanceUnit,
      dropInterval: dropInterval,
      flagFall: flagFall,
      flagDistance: flagDistance,
      extrasIncrement: extrasIncrement,
      distanceRate: distanceRate,
      distanceRateRange: distanceRateRange,
      distanceRate2: distanceRate2,
      distanceRate2Range: distanceRate2Range,
      speedThreshold: speedThreshold,
      timeRate: timeRate,
      journeyTimeRate: journeyTimeRate,
      waitingTimeRate: waitingTimeRate,
      timeRateSpeedThreshold: timeRateSpeedThreshold,
      returnToBoundaryDistanceDate: returnToBoundaryDistanceDate,
      returnToBoundaryMinimumDistance: returnToBoundaryMinimumDistance,
      startTime: startTime,
      endTime: endTime,
      fromDay: fromDay,
      toDay: toDay,
      secretKey: secretKey,
    );
  }
}
