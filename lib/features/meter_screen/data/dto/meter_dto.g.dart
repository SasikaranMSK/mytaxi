// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meter_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeterDto _$MeterDtoFromJson(Map<String, dynamic> json) => MeterDto(
      tripId: json['tripId'] as String,
      distance: (json['distance'] as num).toDouble(),
      waitingTime: (json['waitingTime'] as num).toInt(),
      totalFare: (json['totalFare'] as num).toDouble(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String?,
      tariffId: (json['tariffId'] as num).toInt(),
      vehicleId: (json['vehicleId'] as num).toInt(),
    );

Map<String, dynamic> _$MeterDtoToJson(MeterDto instance) => <String, dynamic>{
      'tripId': instance.tripId,
      'distance': instance.distance,
      'waitingTime': instance.waitingTime,
      'totalFare': instance.totalFare,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'tariffId': instance.tariffId,
      'vehicleId': instance.vehicleId,
    };
