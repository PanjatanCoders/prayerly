// widgets/info_card_widget.dart

import 'package:flutter/material.dart';

class InfoCardWidget extends StatelessWidget {
  final String location;
  final String islamicDate;
  final String currentDate;
  final double? elevation;
  final bool isLoadingElevation;

  const InfoCardWidget({
    super.key,
    required this.location,
    required this.islamicDate,
    required this.currentDate,
    this.elevation,
    this.isLoadingElevation = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location info
          _buildInfoRow(
            icon: Icons.location_on,
            text: location,
            onSurface: onSurface,
            maxLines: 2,
          ),

          const SizedBox(height: 12),

          // Current date
          _buildInfoRow(
            icon: Icons.calendar_today,
            text: currentDate,
            onSurface: onSurface,
          ),

          const SizedBox(height: 12),

          // Islamic date
          _buildInfoRow(
            icon: Icons.nightlight_round,
            text: islamicDate,
            onSurface: onSurface,
          ),

          const SizedBox(height: 12),

          // Elevation info
          _buildElevationRow(onSurface),
        ],
      ),
    );
  }

  /// Builds a generic info row with icon and text
  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color onSurface,
    int maxLines = 1,
  }) {
    return Row(
      children: [
        Icon(icon, color: onSurface, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: onSurface,
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
  Widget _buildElevationRow(Color onSurface) {
    final mutedColor = onSurface.withValues(alpha: 0.6);
    return Row(
      children: [
        Icon(Icons.filter_hdr, color: onSurface, size: 16),
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
                        valueColor: AlwaysStoppedAnimation<Color>(mutedColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Loading elevation...",
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
              : Text(
                  _formatElevationWithFeet(elevation),
                  style: TextStyle(
                    color: mutedColor,
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
  final String currentDate;
  final double? elevation;

  const CompactInfoCardWidget({
    super.key,
    required this.location,
    required this.islamicDate,
    required this.currentDate,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final mutedColor = onSurface.withValues(alpha: 0.6);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location - truncated for compact view
          Row(
            children: [
              Icon(Icons.location_on, color: onSurface, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _truncateLocation(location),
                  style: TextStyle(
                    color: onSurface,
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

          // Current date
          Row(
            children: [
              Icon(Icons.calendar_today, color: onSurface, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  currentDate,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Islamic date
          Row(
            children: [
              Icon(Icons.nightlight_outlined, color: onSurface, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  islamicDate,
                  style: TextStyle(
                    color: onSurface,
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
                Icon(Icons.filter_hdr, color: onSurface, size: 14),
                const SizedBox(width: 4),
                Text(
                  _formatElevationWithFeet(elevation),
                  style: TextStyle(
                    color: mutedColor,
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
