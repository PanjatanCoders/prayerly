// widgets/prayer_times/error_widget.dart
// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import '../../services/prayer_service.dart';

class ErrorWidget extends StatelessWidget {
  final LocationData? locationData;
  final PrayerTimesData? prayerTimesData;
  final VoidCallback onRetry;

  const ErrorWidget({
    super.key,
    required this.locationData,
    required this.prayerTimesData,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    String errorTitle;
    String errorMessage;
    IconData errorIcon;

    if (locationData == null) {
      errorTitle = 'Location Error';
      errorMessage = 'Unable to get your location. Please check location permissions and try again.';
      errorIcon = Icons.location_off;
    } else if (prayerTimesData == null) {
      errorTitle = 'Prayer Times Error';
      errorMessage = 'Unable to calculate prayer times for this location. Try refreshing.';
      errorIcon = Icons.error_outline;
    } else {
      errorTitle = 'Calculation Error';
      errorMessage = 'Unable to calculate prayer status. Please try refreshing the data.';
      errorIcon = Icons.error_outline;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorIcon,
              color: onSurface,
              size: 64,
            ),
            const SizedBox(height: 20),

            Text(
              errorTitle,
              style: TextStyle(
                color: onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              errorMessage,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.7),
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Troubleshooting tips
            _buildTroubleshootingTips(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingTips(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    List<String> tips = [];
    
    if (locationData == null) {
      tips = [
        'Enable location services in device settings',
        'Grant location permission to this app',
        'Try moving to an area with better GPS signal',
        'Once a location has been found it is saved for offline use',
      ];
    } else if (prayerTimesData == null) {
      tips = [
        'Prayer times are calculated on your device - no internet is needed',
        'Refresh to recalculate for your current location',
        'Restart the app if problems persist',
      ];
    }

    if (tips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: onSurface.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.orange[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Troubleshooting Tips:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: onSurface.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}