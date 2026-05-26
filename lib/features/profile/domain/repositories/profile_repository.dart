import 'package:flutter/widgets.dart';
import '../../domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity?> getProfile(String token, BuildContext? context);
}
