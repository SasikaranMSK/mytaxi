import 'package:json_annotation/json_annotation.dart';

part 'location_history_dto.g.dart';

@JsonSerializable()
class LocationHistoryDto {
  final int? id;
  final double lat;
  final double lng;
  final int timestampMillis;

  const LocationHistoryDto({
    this.id,
    required this.lat,
    required this.lng,
    required this.timestampMillis,
  });

  factory LocationHistoryDto.fromJson(Map<String, dynamic> json) =>
      _$LocationHistoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LocationHistoryDtoToJson(this);
}
