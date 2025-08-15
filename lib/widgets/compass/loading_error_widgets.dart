import 'package:flutter/material.dart';

/// Loading widget for Qibla compass initialization
class QiblaLoadingWidget extends StatelessWidget {
  final String message;

  const QiblaLoadingWidget({
    super.key,
    this.message = 'Finding Qibla direction...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.green,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Error widget for Qibla compass failures
class QiblaErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const QiblaErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 20),
            
            Text(
              'Compass Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              _getReadableErrorMessage(errorMessage),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
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
            
            _buildTroubleshootingTips(),
          ],
        ),
      ),
    );
  }

  /// Convert technical error messages to user-friendly ones
  String _getReadableErrorMessage(String error) {
    if (error.toLowerCase().contains('location')) {
      return 'Unable to access your location. Please check that location services are enabled and try again.';
    } else if (error.toLowerCase().contains('compass')) {
      return 'Compass sensor is not available on this device or is not functioning properly.';
    } else if (error.toLowerCase().contains('permission')) {
      return 'Location permission is required to calculate Qibla direction. Please enable location access in settings.';
    } else {
      return 'An unexpected error occurred while initializing the compass.';
    }
  }

  /// Build troubleshooting tips section
  Widget _buildTroubleshootingTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, 
                   color: Colors.orange.shade600, 
                   size: 20),
              const SizedBox(width: 8),
              Text(
                'Troubleshooting Tips:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._buildTipsList(),
        ],
      ),
    );
  }

  /// Build list of troubleshooting tips
  List<Widget> _buildTipsList() {
    final tips = [
      'Enable location services in device settings',
      'Grant location permission to this app',
      'Ensure you\'re not in airplane mode',
      'Move away from magnetic interference',
      'Restart the app if problems persist',
    ];

    return tips.map((tip) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }
}

/// Simple permission request widget
class PermissionRequestWidget extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onGrantPermission;

  const PermissionRequestWidget({
    super.key,
    required this.title,
    required this.description,
    required this.onGrantPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              size: 64,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 20),
            
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: onGrantPermission,
              icon: const Icon(Icons.location_on),
              label: const Text('Grant Permission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
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
          ],
        ),
      ),
    );
  }
}