// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_history_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationHistoryDto _$LocationHistoryDtoFromJson(Map<String, dynamic> json) =>
    LocationHistoryDto(
      id: (json['id'] as num?)?.toInt(),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      timestampMillis: (json['timestampMillis'] as num).toInt(),
    );

Map<String, dynamic> _$LocationHistoryDtoToJson(LocationHistoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lat': instance.lat,
      'lng': instance.lng,
      'timestampMillis': instance.timestampMillis,
    };
