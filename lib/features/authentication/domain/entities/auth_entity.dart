class AuthEntity {
  final String token;
  final String username;
  final String deviceId;

  const AuthEntity({
    required this.token,
    required this.username,
    required this.deviceId,
  });
}
