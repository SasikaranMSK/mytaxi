// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tariff_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TariffDto _$TariffDtoFromJson(Map<String, dynamic> json) => TariffDto(
      tarifId: (json['tarifId'] as num).toInt(),
      tarifName: json['tarifName'] as String,
      description: json['description'] as String?,
      active: json['active'] as bool,
      defaultTariff: json['default'] as bool,
      publicHolidays: json['publicHolidays'] as bool,
      bankHolidays: json['bankHolidays'] as bool,
      distanceUnit: json['distanceUnit'] as String,
      dropInterval: (json['dropInterval'] as num).toInt(),
      flagFall: (json['flagFall'] as num).toDouble(),
      flagDistance: (json['flagDistance'] as num).toDouble(),
      extrasIncrement: (json['extrasIncrement'] as num).toDouble(),
      distanceRate: (json['distanceRate'] as num).toDouble(),
      distanceRateRange: (json['distanceRateRange'] as num).toDouble(),
      distanceRate2: (json['distanceRate2'] as num).toDouble(),
      distanceRate2Range: (json['distanceRate2Range'] as num).toDouble(),
      speedThreshold: (json['speedThreshold'] as num).toDouble(),
      timeRate: (json['timeRate'] as num).toDouble(),
      journeyTimeRate: (json['journeyTimeRate'] as num).toDouble(),
      waitingTimeRate: (json['waitingTimeRate'] as num).toDouble(),
      timeRateSpeedThreshold:
          (json['timeRateSpeedThreshold'] as num).toDouble(),
      returnToBoundaryDistanceDate:
          (json['returnToBoundaryDistanceDate'] as num).toDouble(),
      returnToBoundaryMinimumDistance:
          (json['returnToBoundaryMinimumDistance'] as num).toDouble(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      fromDay: (json['fromDay'] as num).toInt(),
      toDay: (json['toDay'] as num).toInt(),
      secretKey: json['secretKey'] as String,
    );

Map<String, dynamic> _$TariffDtoToJson(TariffDto instance) => <String, dynamic>{
      'tarifId': instance.tarifId,
      'tarifName': instance.tarifName,
      'description': instance.description,
      'active': instance.active,
      'default': instance.defaultTariff,
      'publicHolidays': instance.publicHolidays,
      'bankHolidays': instance.bankHolidays,
      'distanceUnit': instance.distanceUnit,
      'dropInterval': instance.dropInterval,
      'flagFall': instance.flagFall,
      'flagDistance': instance.flagDistance,
      'extrasIncrement': instance.extrasIncrement,
      'distanceRate': instance.distanceRate,
      'distanceRateRange': instance.distanceRateRange,
      'distanceRate2': instance.distanceRate2,
      'distanceRate2Range': instance.distanceRate2Range,
      'speedThreshold': instance.speedThreshold,
      'timeRate': instance.timeRate,
      'journeyTimeRate': instance.journeyTimeRate,
      'waitingTimeRate': instance.waitingTimeRate,
      'timeRateSpeedThreshold': instance.timeRateSpeedThreshold,
      'returnToBoundaryDistanceDate': instance.returnToBoundaryDistanceDate,
      'returnToBoundaryMinimumDistance':
          instance.returnToBoundaryMinimumDistance,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'fromDay': instance.fromDay,
      'toDay': instance.toDay,
      'secretKey': instance.secretKey,
    };
