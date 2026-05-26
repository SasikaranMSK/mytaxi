import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  final String id;
  final String userName;
  final String email;
  final String phoneNumber;
  final String createdAt;

  const UserDto({
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
