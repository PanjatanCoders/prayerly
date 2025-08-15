// widgets/qibla_info_widget.dart
import 'package:flutter/material.dart';
import '../../models/qibla_data.dart';
import '../../services/qibla_service.dart';

/// Widget displaying Qibla information in cards
class QiblaInfoWidget extends StatelessWidget {
  final QiblaData qiblaData;

  const QiblaInfoWidget({
    super.key,
    required this.qiblaData,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = QiblaService.getAccuracyStatus(qiblaData.bearing);
    final direction = QiblaService.getDirectionString(qiblaData.direction);
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // First row: Direction and Distance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem(
                  icon: Icons.explore,
                  title: 'Direction',
                  value: direction,
                  color: Colors.blue,
                ),
                _buildInfoItem(
                  icon: Icons.straighten,
                  title: 'Distance',
                  value: '${qiblaData.distance.toStringAsFixed(0)} km',
                  color: Colors.orange,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Second row: Accuracy and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem(
                  icon: Icons.gps_fixed,
                  title: 'Accuracy',
                  value: accuracy,
                  color: _getAccuracyColor(accuracy),
                ),
                _buildInfoItem(
                  icon: Icons.schedule,
                  title: 'Updated',
                  value: _formatTime(qiblaData.calculatedAt),
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual info item with icon, title, and value
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Get color based on accuracy status
  Color _getAccuracyColor(String accuracy) {
    switch (accuracy) {
      case 'Perfect Alignment':
        return Colors.green;
      case 'Very Good':
        return Colors.lightGreen;
      case 'Good':
        return Colors.yellow.shade700;
      case 'Fair':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  /// Format time for display
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Widget for displaying Qibla direction banner
class QiblaDirectionBanner extends StatelessWidget {
  final QiblaData qiblaData;

  const QiblaDirectionBanner({
    super.key,
    required this.qiblaData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade800.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            QiblaService.getDirectionIcon(qiblaData.direction),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'Qibla is ${qiblaData.direction.toStringAsFixed(1)}° ${QiblaService.getDirectionString(qiblaData.direction)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}