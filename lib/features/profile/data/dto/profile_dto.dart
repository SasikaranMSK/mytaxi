import 'package:json_annotation/json_annotation.dart';
import 'user_dto.dart';

part 'profile_dto.g.dart';

@JsonSerializable()
class ProfileDto {
  final int id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String? dateOfBirth;
  final String mobile;
  final String phoneNumber;
  final String? profilePhoto;
  final String username;
  final String email;
  final String? address;
  final String? mapLatitude;
  final String? mapLongitude;
  final String userId;
  final UserDto user;

  const ProfileDto({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    this.dateOfBirth,
    required this.mobile,
    required this.phoneNumber,
    this.profilePhoto,
    required this.username,
    required this.email,
    this.address,
    this.mapLatitude,
    this.mapLongitude,
    required this.userId,
    required this.user,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDtoToJson(this);
}
