// widgets/info_card_widget.dart
import 'package:flutter/material.dart';
import '../services/elevation_service.dart';

class InfoCardWidget extends StatelessWidget {
  final String location;
  final String islamicDate;
  final double? elevation;
  final bool isLoadingElevation;

  const InfoCardWidget({
    super.key,
    required this.location,
    required this.islamicDate,
    this.elevation,
    this.isLoadingElevation = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location info
          _buildInfoRow(
            icon: Icons.location_on,
            text: location,
            maxLines: 2,
          ),

          const SizedBox(height: 12),

          // Islamic date
          _buildInfoRow(
            icon: Icons.calendar_today,
            text: islamicDate,
          ),

          const SizedBox(height: 12),

          // Elevation info
          _buildElevationRow(),
        ],
      ),
    );
  }

  /// Builds a generic info row with icon and text
  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    int maxLines = 1,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds the elevation row with loading state
  Widget _buildElevationRow() {
    return Row(
      children: [
        const Icon(Icons.filter_hdr, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: isLoadingElevation
              ? Row(
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Loading elevation...",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          )
              : Text(
            _formatElevationWithFeet(elevation),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  /// Formats elevation showing both meters and feet
  String _formatElevationWithFeet(double? elevation) {
    if (elevation == null) return 'Elevation unavailable';

    final meters = elevation.round();
    final feet = (elevation * 3.28084).round(); // 1 meter = 3.28084 feet

    return '${meters}m (${feet}ft)';
  }
}

/// Compact version of info card for smaller spaces
class CompactInfoCardWidget extends StatelessWidget {
  final String location;
  final String islamicDate;
  final double? elevation;

  const CompactInfoCardWidget({
    super.key,
    required this.location,
    required this.islamicDate,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location - truncated for compact view
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _truncateLocation(location),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Islamic date
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  islamicDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          if (elevation != null) ...[
            const SizedBox(height: 8),

            // Elevation
            Row(
              children: [
                const Icon(Icons.filter_hdr, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  _formatElevationWithFeet(elevation),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Truncates location for compact display
  String _truncateLocation(String location) {
    final parts = location.split(', ');
    if (parts.length > 2) {
      return '${parts[0]}, ${parts[parts.length - 1]}';
    }
    return location;
  }

  /// Formats elevation showing both meters and feet
  String _formatElevationWithFeet(double? elevation) {
    if (elevation == null) return 'Elevation unavailable';

    final meters = elevation.round();
    final feet = (elevation * 3.28084).round(); // 1 meter = 3.28084 feet

    return '${meters}m (${feet}ft)';
  }
}