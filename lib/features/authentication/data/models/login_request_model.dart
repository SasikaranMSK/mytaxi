class LoginRequestModel {
  final String username;
  final String password;
  final String macAddress;

  LoginRequestModel({
    required this.username,
    required this.password,
    required this.macAddress,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'macAddress': macAddress,
      };

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      LoginRequestModel(
        username: json['username'],
        password: json['password'],
        macAddress: json['macAddress'] ?? '',
      );
}
