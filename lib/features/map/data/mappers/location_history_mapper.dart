import '../../domain/entities/location_history_entity.dart';
import '../dto/location_history_dto.dart';
import '../models/location_history_model.dart';

extension LocationHistoryEntityMapper on LocationHistoryEntity {
  LocationHistoryDto toDto() => LocationHistoryDto(
        id: id,
        lat: lat,
        lng: lng,
        timestampMillis: timestamp.millisecondsSinceEpoch,
      );
}

extension LocationHistoryDtoMapper on LocationHistoryDto {
  LocationHistoryEntity toEntity() => LocationHistoryEntity(
        id: id,
        lat: lat,
        lng: lng,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true),
      );

  LocationHistoryModel toModel() => LocationHistoryModel(
        id: id,
        lat: lat,
        lng: lng,
        timestamp: timestampMillis,
      );
}

extension LocationHistoryModelMapper on LocationHistoryModel {
  LocationHistoryDto toDto() => LocationHistoryDto(
        id: id,
        lat: lat,
        lng: lng,
        timestampMillis: timestamp,
      );

  LocationHistoryEntity toEntity() => toDto().toEntity();
}
