import '../../domain/entities/profile_entity.dart';
import '../dto/profile_dto.dart';
import 'user_model.dart';

class ProfileModel {
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
  final UserModel user;

  const ProfileModel({
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

  factory ProfileModel.fromDto(ProfileDto dto) {
    return ProfileModel(
      id: dto.id,
      firstName: dto.firstName,
      middleName: dto.middleName,
      lastName: dto.lastName,
      dateOfBirth: dto.dateOfBirth,
      mobile: dto.mobile,
      phoneNumber: dto.phoneNumber,
      profilePhoto: dto.profilePhoto,
      username: dto.username,
      email: dto.email,
      address: dto.address,
      mapLatitude: dto.mapLatitude,
      mapLongitude: dto.mapLongitude,
      userId: dto.userId,
      user: UserModel.fromDto(dto.user),
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      mobile: mobile,
      phoneNumber: phoneNumber,
      profilePhoto: profilePhoto,
      username: username,
      email: email,
      address: address,
      mapLatitude: mapLatitude,
      mapLongitude: mapLongitude,
      userId: userId,
      user: user.toEntity(),
    );
  }
}
