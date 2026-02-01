// widgets/prayer_times/menu_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:prayerly/screens/dhikr/dhikr_selection_screen.dart';
import '../../screens/adhan_settings_screen.dart';
import '../../screens/qaza/qaza_tracker_screen.dart';
import '../../screens/zakat/zakat_screen.dart';

class MenuBottomSheet extends StatelessWidget {
  const MenuBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Menu title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Qaza Tracker Option
          _buildMenuTile(
            context: context,
            icon: Icons.format_list_numbered,
            iconColor: Colors.green,
            title: 'Qaza Tracker',
            subtitle: 'Track missed prayers',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QazaTrackerScreen(),
                ),
              );
            },
          ),

          // Zakat Calculator Option
          _buildMenuTile(
            context: context,
            icon: Icons.volunteer_activism,
            iconColor: Colors.teal,
            title: 'Zakat Calculator',
            subtitle: 'Calculate & track Zakat',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ZakatScreen(),
                ),
              );
            },
          ),

          // Dhikr Counter Option - UPDATED
          _buildMenuTile(
            context: context,
            icon: Icons.circle_outlined,
            iconColor: Colors.purple,
            title: 'Dhikr Counter',
            subtitle: 'Digital Tasbih counter',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DhikrSelectionScreen(),
                ),
              );
            },
          ),
          
          // Settings Option
          _buildMenuTile(
            context: context,
            icon: Icons.settings,
            iconColor: Colors.blue,
            title: 'Settings',
            subtitle: 'Adhan & notifications',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdhanSettingsScreen(),
                ),
              );
            },
          ),
          
          // Prayer Calendar Option
          _buildMenuTile(
            context: context,
            icon: Icons.calendar_month,
            iconColor: Colors.orange,
            title: 'Prayer Calendar',
            subtitle: 'Monthly prayer times',
            onTap: () {
              Navigator.pop(context);
              // Navigate to Prayer Calendar when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prayer Calendar coming soon!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}