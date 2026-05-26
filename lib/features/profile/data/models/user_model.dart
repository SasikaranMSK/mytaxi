import '../../domain/entities/user_entity.dart';
import '../dto/user_dto.dart';

class UserModel {
  final String id;
  final String userName;
  final String email;
  final String phoneNumber;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory UserModel.fromDto(UserDto dto) {
    return UserModel(
      id: dto.id,
      userName: dto.userName,
      email: dto.email,
      phoneNumber: dto.phoneNumber,
      createdAt: dto.createdAt,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      userName: userName,
      email: email,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
    );
  }
}
