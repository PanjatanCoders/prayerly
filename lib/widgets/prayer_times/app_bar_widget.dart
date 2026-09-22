// widgets/prayer_times/app_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:prayerly/screens/dhikr/dhikr_selection_screen.dart';
import 'package:prayerly/utils/theme/app_transitions.dart';
import '../../screens/compass/qibla_compass_screen.dart';

class PrayerTimesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool notificationsEnabled;
  final VoidCallback onToggleNotifications;
  final VoidCallback onRefresh;
  final VoidCallback onShowInfo;
  final VoidCallback onShowMenu;

  const PrayerTimesAppBar({
    super.key,
    required this.notificationsEnabled,
    required this.onToggleNotifications,
    required this.onRefresh,
    required this.onShowInfo,
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
          Icon(Icons.brightness_6, color: onSurface),
          const SizedBox(width: 8),
          Text(
            'Prayerly',
            style: TextStyle(color: onSurface, fontSize: 16),
          ),
        ],
      ),
      actions: [
        // Notification toggle button
        IconButton(
          icon: Icon(
            notificationsEnabled ? Icons.notifications : Icons.notifications_off,
            color: notificationsEnabled ? Colors.orange : onSurface.withValues(alpha: 0.5),
          ),
          onPressed: onToggleNotifications,
          tooltip: notificationsEnabled
              ? 'Disable Notifications'
              : 'Enable Notifications',
        ),

        // Dhikr Counter button - NEW
        IconButton(
          icon: const Icon(Icons.circle_outlined, color: Colors.purple),
          onPressed: () {
            Navigator.push(
              context,
              AppTransitions.slideIn(const DhikrSelectionScreen()),
            );
          },
          tooltip: 'Dhikr Counter',
        ),

        // Compass button
        IconButton(
          icon: Icon(Icons.compass_calibration_outlined, color: onSurface),
          onPressed: () {
            Navigator.push(
              context,
              AppTransitions.slideIn(const QiblaCompassScreen()),
            );
          },
          tooltip: 'Qibla Compass',
        ),

        // Refresh button
        IconButton(
          icon: Icon(Icons.refresh, color: onSurface),
          onPressed: onRefresh,
          tooltip: 'Refresh Data',
        ),

        // Info button
        IconButton(
          icon: Icon(Icons.info_outline, color: onSurface),
          onPressed: onShowInfo,
          tooltip: 'App Information',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}