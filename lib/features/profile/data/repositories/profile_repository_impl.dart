import 'package:flutter/widgets.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileEntity?> getProfile(String token, BuildContext? context) async {
    final dto = await remoteDataSource.getProfile(token, context);
    if (dto == null) return null;

    final model = ProfileModel.fromDto(dto);
    return model.toEntity();
  }
}
