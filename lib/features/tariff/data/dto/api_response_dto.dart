import 'package:json_annotation/json_annotation.dart';

part 'api_response_dto.g.dart';

/// Generic API Response DTO
@JsonSerializable(genericArgumentFactories: true)
class ApiResponseDto<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic errors;

  ApiResponseDto({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  /// From JSON
  factory ApiResponseDto.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) => _$ApiResponseDtoFromJson(json, fromJsonT);

  /// To JSON
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseDtoToJson(this, toJsonT);
}
