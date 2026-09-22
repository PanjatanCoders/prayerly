// widgets/prayer_times/info_dialog_widget.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return AlertDialog(
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
          Text(
            'App Information',
            style: TextStyle(color: onSurface),
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
              context,
              'Calculation Method',
              'University of Islamic Sciences, Karachi',
              Icons.calculate,
            ),
            _buildInfoItem(
              context,
              'Juristic Method',
              'Hanafi (Asr at twice the shadow length)',
              Icons.school,
            ),

            const SizedBox(height: 16),
            _buildSectionTitle('Location'),
            _buildInfoItem(
              context,
              'Location Source',
              _locationSourceLabel(locationData?.source),
              Icons.location_on,
            ),
            if (locationData != null)
              _buildInfoItem(
                context,
                'Coordinates',
                locationData!.formattedCoordinates,
                Icons.my_location,
              ),
            if (elevation != null)
              _buildInfoItem(
                context,
                'Elevation',
                ElevationService.formatElevationWithBothUnits(elevation),
                Icons.height,
              ),

            const SizedBox(height: 16),
            _buildSectionTitle('Data'),
            _buildInfoItem(
              context,
              'Prayer Times Source',
              'Calculated on this device (no internet needed)',
              Icons.calculate_outlined,
            ),
            _buildInfoItem(
              context,
              'Notifications',
              notificationsEnabled ? 'Enabled (Auto Adhan)' : 'Disabled',
              notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
            ),

            const SizedBox(height: 16),
            _buildSectionTitle('App Version'),
            // Read from the package rather than hard-coded: the literal here
            // said 1.0.0 while the app shipped as 2.x, and "Last Update" was
            // DateTime.now(), so it always claimed to have been updated today.
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final info = snapshot.data;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfoItem(
                      context,
                      'Version',
                      info?.version ?? '...',
                      Icons.info,
                    ),
                    _buildInfoItem(
                      context,
                      'Build',
                      info?.buildNumber ?? '...',
                      Icons.numbers,
                    ),
                  ],
                );
              },
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
          child: const Text('Close'),
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

  /// Describes which tier of the location fallback chain was used, so the
  /// user can tell a live fix from a replayed one.
  static String _locationSourceLabel(LocationSource? source) {
    switch (source) {
      case LocationSource.gps:
        return 'GPS / device location';
      case LocationSource.lastKnown:
        return 'Last known device fix';
      case LocationSource.cache:
        return 'Saved location (offline)';
      case LocationSource.fallback:
        return 'Default location (no fix available)';
      case null:
        return 'Unknown';
    }
  }

  Widget _buildInfoItem(BuildContext context, String label, String? value, IconData icon) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Not available',
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.6),
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