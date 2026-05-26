import '../../domain/entities/auth_entity.dart';
import '../dto/auth_dto.dart';
import '../models/auth_model.dart';

extension AuthEntityMapper on AuthEntity {
  AuthDto toDto() => AuthDto(
        token: token,
        username: username,
        deviceId: deviceId,
      );
}

extension AuthDtoMapper on AuthDto {
  AuthEntity toEntity() => AuthEntity(
        token: token ?? '',
        username: username ?? '',
        deviceId: deviceId ?? '',
      );

  AuthModel toModel() => AuthModel(
        token: token,
        username: username,
        deviceId: deviceId,
      );
}

extension AuthModelMapper on AuthModel {
  AuthDto toDto() => AuthDto(
        token: token,
        username: username,
        deviceId: deviceId,
      );

  AuthEntity toEntity() => toDto().toEntity();
}
