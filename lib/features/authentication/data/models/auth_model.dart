class AuthModel {
  final String? token;
  final String? username;
  final String? deviceId;

  const AuthModel({
    this.token,
    this.username,
    this.deviceId,
  });

  AuthModel copyWith({
    String? token,
    String? username,
    String? deviceId,
  }) {
    return AuthModel(
      token: token ?? this.token,
      username: username ?? this.username,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token']?.toString(),
      username: json['username']?.toString(),
      deviceId: (json['deviceId'] ?? json['device_id'] ?? json['macAddress'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'username': username,
      'deviceId': deviceId,
    };
  }
}
