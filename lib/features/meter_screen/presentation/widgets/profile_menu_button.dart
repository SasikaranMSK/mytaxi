import 'package:flutter/material.dart';
import '../../../authentication/domain/usecases/authentications/logout_usecase.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/constants/route_constants.dart';

class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.transparent,
          child: Icon(Icons.person, color: Colors.white, size: 24),
        ),
      ),
      color: const Color(0xFF26333D),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.account_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Text('View Profile', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              const Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'profile':
            Navigator.pushNamed(context, RouteConstants.profile);
            break;
          case 'logout':
            await _handleLogout(context);
            break;
        }
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF26333D),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final logoutUseCase = sl<LogoutUseCase>();
        await logoutUseCase();

        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(RouteConstants.login, (route) => false);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
