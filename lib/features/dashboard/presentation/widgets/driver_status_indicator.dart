import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../domain/entities/driver_status_entity.dart';

class DriverStatusIndicator extends StatelessWidget {
  final DriverStatusEntity status;
  final VoidCallback? onStartWork;

  const DriverStatusIndicator({
    super.key,
    required this.status,
    this.onStartWork,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: status.isOnDuty
              ? [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)]
              : [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusItem(
                      icon: Icons.power_settings_new,
                      label: 'Online',
                      isActive: status.isOnline,
                      activeColor: kGreenColor,
                    ),
                    _buildStatusItem(
                      icon: Icons.work,
                      label: 'On Duty',
                      isActive: status.isOnDuty,
                      activeColor: kOrangeColor,
                    ),
                    _buildStatusItem(
                      icon: Icons.directions_car,
                      label: 'Vehicle',
                      isActive: status.isVehicleActivated,
                      activeColor: kAccentColor,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: kPrimaryText.withOpacity(0.7),
                  size: 24,
                ),
                onPressed: () => _showStatusInfoDialog(context),
                tooltip: 'Status Information',
              ),
            ],
          ),
          if (!status.isOnDuty && onStartWork != null) ...[
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onStartWork,
                icon: const Icon(Icons.play_arrow, size: 24),
                label: const Text(
                  'START WORK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: kPrimaryText,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
  }) {
    final Color iconColor = isActive ? activeColor : kSecondaryText;
    final Color borderColor = isActive
        ? activeColor
        : kSecondaryText.withOpacity(0.3);
    final Color backgroundColor = isActive
        ? activeColor.withOpacity(0.15)
        : kBgColor.withOpacity(0.3);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: isActive ? activeColor : kSecondaryText,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? activeColor : kSecondaryText.withOpacity(0.4),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }

  void _showStatusInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        title: const Text(
          'Driver Status Guide',
          style: TextStyle(
            color: kPrimaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem(
                icon: Icons.power_settings_new,
                label: 'Online',
                color: kGreenColor,
                description:
                    'You are connected to the system and can receive job notifications. Toggle this when you want to be discoverable.',
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                icon: Icons.work,
                label: 'On Duty',
                color: kOrangeColor,
                description:
                    'You are actively working and can accept jobs. You must have a validated vehicle and be online before going on duty.',
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                icon: Icons.directions_car,
                label: 'Vehicle',
                color: kAccentColor,
                description:
                    'Your vehicle is validated and activated. Insurance and documents must be current for vehicle activation.',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kAccentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: kAccentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: kAccentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Press "START WORK" to activate all statuses at once if your vehicle is already registered.',
                        style: TextStyle(
                          color: kPrimaryText.withOpacity(0.9),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: kAccentColor),
            child: const Text(
              'GOT IT',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required Color color,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: kSecondaryText,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
