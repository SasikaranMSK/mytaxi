import 'user_entity.dart';

class ProfileEntity {
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
  final UserEntity user;

  const ProfileEntity({
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

  String get fullName {
    final parts = [
      firstName,
      middleName,
      lastName,
    ].where((part) => part.isNotEmpty).toList();
    return parts.isEmpty ? username : parts.join(' ');
  }
}
