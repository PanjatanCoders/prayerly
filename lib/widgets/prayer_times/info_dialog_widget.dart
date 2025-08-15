// widgets/prayer_times/info_dialog_widget.dart
import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import '../../services/prayer_service.dart';
import '../../services/elevation_service.dart';

class InfoDialogWidget extends StatelessWidget {
  final LocationData? locationData;
  final PrayerTimesData? prayerTimesData;
  final double? elevation;
  final bool notificationsEnabled;
  final VoidCallback onToggleNotifications;

  const InfoDialogWidget({
    super.key,
    required this.locationData,
    required this.prayerTimesData,
    required this.elevation,
    required this.notificationsEnabled,
    required this.onToggleNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[400],
          ),
          const SizedBox(width: 8),
          const Text(
            'App Information',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Prayer Calculation'),
            _buildInfoItem(
              'Calculation Method',
              'University of Islamic Sciences, Karachi',
              Icons.calculate,
            ),
            _buildInfoItem(
              'Juristic Method',
              'Standard (Shafi, Maliki, Hanbali)',
              Icons.school,
            ),
            
            const SizedBox(height: 16),
            _buildSectionTitle('Location'),
            _buildInfoItem(
              'Location Source',
              locationData?.isDefault == true
                  ? 'Default (Permission denied)'
                  : 'GPS Location',
              Icons.location_on,
            ),
            if (elevation != null)
              _buildInfoItem(
                'Elevation',
                ElevationService.formatElevationWithBothUnits(elevation),
                Icons.height,
              ),
            
            const SizedBox(height: 16),
            _buildSectionTitle('Data'),
            _buildInfoItem(
              'Prayer Times Source',
              prayerTimesData?.isDefault == true ? 'Fallback Data' : 'API Data',
              Icons.cloud,
            ),
            _buildInfoItem(
              'Notifications',
              notificationsEnabled ? 'Enabled (Auto Adhan)' : 'Disabled',
              notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
            ),
            
            const SizedBox(height: 16),
            _buildSectionTitle('App Version'),
            _buildInfoItem(
              'Version',
              '1.0.0',
              Icons.info,
            ),
            _buildInfoItem(
              'Last Update',
              DateTime.now().toString().split(' ')[0],
              Icons.update,
            ),
          ],
        ),
      ),
      actions: [
        if (!notificationsEnabled)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onToggleNotifications();
            },
            icon: const Icon(Icons.notifications, color: Colors.orange),
            label: const Text(
              'Enable Notifications',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Close',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blue[300],
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Not available',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}