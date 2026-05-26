import 'package:json_annotation/json_annotation.dart';

part 'meter_dto.g.dart';

@JsonSerializable()
class MeterDto {
  final String tripId;
  final double distance;
  final int waitingTime;
  final double totalFare;
  final String startTime;
  final String? endTime;
  final int tariffId;
  final int vehicleId;

  const MeterDto({
    required this.tripId,
    required this.distance,
    required this.waitingTime,
    required this.totalFare,
    required this.startTime,
    this.endTime,
    required this.tariffId,
    required this.vehicleId,
  });

  factory MeterDto.fromJson(Map<String, dynamic> json) =>
      _$MeterDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MeterDtoToJson(this);
}
