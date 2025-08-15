// widgets/prayer_times/app_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:prayerly/screens/dhikr/dhikr_selection_screen.dart';
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
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: onShowMenu,
        child: const Icon(Icons.menu, color: Colors.white),
      ),
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.brightness_6, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Prayerly',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
      actions: [
        // Notification toggle button
        IconButton(
          icon: Icon(
            notificationsEnabled ? Icons.notifications : Icons.notifications_off,
            color: notificationsEnabled ? Colors.orange : Colors.grey,
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
              MaterialPageRoute(
                builder: (context) => const DhikrSelectionScreen(),
              ),
            );
          },
          tooltip: 'Dhikr Counter',
        ),
        
        // Compass button
        IconButton(
          icon: const Icon(Icons.compass_calibration_outlined, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QiblaCompassScreen(),
              ),
            );
          },
          tooltip: 'Qibla Compass',
        ),
        
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: onRefresh,
          tooltip: 'Refresh Data',
        ),
        
        // Info button
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: onShowInfo,
          tooltip: 'App Information',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}