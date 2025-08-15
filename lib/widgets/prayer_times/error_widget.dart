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
    String errorTitle;
    String errorMessage;
    IconData errorIcon;

    if (locationData == null) {
      errorTitle = 'Location Error';
      errorMessage = 'Unable to get your location. Please check location permissions and try again.';
      errorIcon = Icons.location_off;
    } else if (prayerTimesData == null) {
      errorTitle = 'Prayer Times Error';
      errorMessage = 'Unable to fetch prayer times. Please check your internet connection and try again.';
      errorIcon = Icons.cloud_off;
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
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 20),
            
            Text(
              errorTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.grey[400],
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
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
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
            _buildTroubleshootingTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingTips() {
    List<String> tips = [];
    
    if (locationData == null) {
      tips = [
        'Enable location services in device settings',
        'Grant location permission to this app',
        'Ensure you\'re not in airplane mode',
        'Try moving to an area with better GPS signal',
      ];
    } else if (prayerTimesData == null) {
      tips = [
        'Check your internet connection',
        'Try connecting to Wi-Fi',
        'Restart the app if problems persist',
        'Contact support if issue continues',
      ];
    }

    if (tips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
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
                  color: Colors.grey[300],
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
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      color: Colors.grey[400],
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