import 'package:flutter/material.dart';

import '../constants/color_constants.dart';
import '../constants/route_constants.dart';

enum BottomNavTab { fare, map }

class BottomNavTabs extends StatelessWidget {
  final BottomNavTab activeTab;
  const BottomNavTabs({super.key, required this.activeTab});

  void _goTo(BuildContext context, BottomNavTab tab) {
    if (tab == activeTab) return;

    if (tab == BottomNavTab.fare) {
      var found = false;
      Navigator.of(context).popUntil((route) {
        if (route.settings.name == RouteConstants.meter) {
          found = true;
          return true;
        }
        return route.isFirst;
      });

      if (!found) {
        Navigator.pushNamed(context, RouteConstants.meter);
      }
      return;
    }

    Navigator.pushNamed(context, RouteConstants.map);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                label: 'FARE',
                icon: Icons.payments_outlined,
                isActive: activeTab == BottomNavTab.fare,
                onTap: () => _goTo(context, BottomNavTab.fare),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TabButton(
                label: 'MAP',
                icon: Icons.map_outlined,
                isActive: activeTab == BottomNavTab.map,
                onTap: () => _goTo(context, BottomNavTab.map),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? kAccentColor : Colors.white.withValues(alpha: 0.08);
    final fg = isActive ? Colors.black : Colors.white;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
