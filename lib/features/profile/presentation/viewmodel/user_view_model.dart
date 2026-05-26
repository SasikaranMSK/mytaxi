import '../../domain/entities/user_entity.dart';

class UserViewModel {
  final String id;
  final String userName;
  final String email;
  final String phoneNumber;
  final String createdAt;

  const UserViewModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory UserViewModel.fromEntity(UserEntity e) {
    return UserViewModel(
      id: e.id,
      userName: e.userName,
      email: e.email,
      phoneNumber: e.phoneNumber,
      createdAt: e.createdAt,
    );
  }

  // UI helper
  String get createdAtText {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return createdAt;
    }
  }
}
