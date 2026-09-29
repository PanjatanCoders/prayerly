// widgets/prayer_times/app_bar_widget.dart
import 'package:flutter/material.dart';

/// The Dhikr Counter and Qibla Compass buttons this bar used to carry were
/// removed: both destinations are already one tap away from the persistent
/// bottom nav bar in [HomeShell], so duplicating them here was redundant.
/// [onShowInfo] stays reachable from the sidebar drawer instead of a
/// dedicated button, keeping this bar down to menu / title / notifications /
/// refresh - matching the target design.
class PrayerTimesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool notificationsEnabled;
  final VoidCallback onToggleNotifications;
  final VoidCallback onRefresh;
  final VoidCallback onShowMenu;

  const PrayerTimesAppBar({
    super.key,
    required this.notificationsEnabled,
    required this.onToggleNotifications,
    required this.onRefresh,
    required this.onShowMenu,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: onShowMenu,
        child: Icon(Icons.menu, color: onSurface),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mosque, color: onSurface, size: 22),
          const SizedBox(width: 8),
          Text(
            'Prayerly',
            style: TextStyle(
              color: onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Badge(
            isLabelVisible: notificationsEnabled,
            backgroundColor: Colors.red,
            smallSize: 8,
            child: Icon(Icons.notifications_outlined, color: onSurface),
          ),
          onPressed: onToggleNotifications,
          tooltip: notificationsEnabled
              ? 'Disable Notifications'
              : 'Enable Notifications',
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: onSurface),
          onPressed: onRefresh,
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}