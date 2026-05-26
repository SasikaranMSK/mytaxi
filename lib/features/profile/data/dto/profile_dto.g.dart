// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => ProfileDto(
      id: (json['id'] as num).toInt(),
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: json['dateOfBirth'] as String?,
      mobile: json['mobile'] as String,
      phoneNumber: json['phoneNumber'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      username: json['username'] as String,
      email: json['email'] as String,
      address: json['address'] as String?,
      mapLatitude: json['mapLatitude'] as String?,
      mapLongitude: json['mapLongitude'] as String?,
      userId: json['userId'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileDtoToJson(ProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'middleName': instance.middleName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth,
      'mobile': instance.mobile,
      'phoneNumber': instance.phoneNumber,
      'profilePhoto': instance.profilePhoto,
      'username': instance.username,
      'email': instance.email,
      'address': instance.address,
      'mapLatitude': instance.mapLatitude,
      'mapLongitude': instance.mapLongitude,
      'userId': instance.userId,
      'user': instance.user,
    };
