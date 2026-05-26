import '../../domain/entities/profile_entity.dart';
import 'user_view_model.dart';

class ProfileViewModel {
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
  final UserViewModel user;

  const ProfileViewModel({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.dateOfBirth,
    required this.mobile,
    required this.phoneNumber,
    required this.profilePhoto,
    required this.username,
    required this.email,
    required this.address,
    required this.mapLatitude,
    required this.mapLongitude,
    required this.userId,
    required this.user,
  });

  factory ProfileViewModel.fromEntity(ProfileEntity e) {
    return ProfileViewModel(
      id: e.id,
      firstName: e.firstName,
      middleName: e.middleName,
      lastName: e.lastName,
      dateOfBirth: e.dateOfBirth,
      mobile: e.mobile,
      phoneNumber: e.phoneNumber,
      profilePhoto: e.profilePhoto,
      username: e.username,
      email: e.email,
      address: e.address,
      mapLatitude: e.mapLatitude,
      mapLongitude: e.mapLongitude,
      userId: e.userId,
      user: UserViewModel.fromEntity(e.user),
    );
  }

  // UI helpers (Screen-la formatting repeat ஆகாம)
  String get fullName {
    final parts = [firstName, middleName, lastName]
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? username : parts.join(' ');
  }

  String get usernameText => '@${username.trim()}';

  String get addressText =>
      (address == null || address!.trim().isEmpty) ? '' : address!.trim();

  bool get hasAddress => addressText.isNotEmpty;

  String get mobileText => mobile.trim();
  String get phoneText => phoneNumber.trim();
  String get emailText => email.trim();
}
