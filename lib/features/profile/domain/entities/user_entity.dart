class UserEntity {
  final String id;
  final String userName;
  final String email;
  final String phoneNumber;
  final String createdAt;

  const UserEntity({
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
  });
}
