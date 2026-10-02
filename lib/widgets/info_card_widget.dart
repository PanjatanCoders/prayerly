// widgets/info_card_widget.dart

import 'package:flutter/material.dart';
import '../services/weather_service.dart';

/// Location, date and current-weather summary shown on the semi-opaque card
/// over the hero photo. Always renders in dark text on the assumption of a
/// light (near-white) card background, regardless of app theme - see
/// [HeroStatusCard]'s `_LocationDateCard`.
class InfoCardWidget extends StatelessWidget {
  final String location;
  final String islamicDate;
  final String currentDate;
  final WeatherSnapshot? weather;
  final bool isLoadingWeather;

  const InfoCardWidget({
    super.key,
    required this.location,
    required this.islamicDate,
    required this.currentDate,
    this.weather,
    this.isLoadingWeather = false,
  });

  @override
  Widget build(BuildContext context) {
    final locationParts = _splitFirst(location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconRow(
          icon: Icons.location_on,
          primary: locationParts.$1,
          secondary: locationParts.$2,
        ),
        const SizedBox(height: 8),
        _buildIconRow(
          icon: Icons.calendar_today,
          primary: currentDate,
          secondary: islamicDate,
        ),
        const SizedBox(height: 8),
        _buildWeatherRow(),
      ],
    );
  }

  /// Splits "Neighborhood, City, Country" into a bold first line and a
  /// muted remainder line, matching the reference design's two-line address.
  (String, String?) _splitFirst(String text) {
    final commaIndex = text.indexOf(',');
    if (commaIndex == -1) return (text, null);
    return (
      '${text.substring(0, commaIndex)},',
      text.substring(commaIndex + 1).trim(),
    );
  }

  Widget _buildIconRow({
    required IconData icon,
    required String primary,
    String? secondary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black54, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primary,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (secondary != null && secondary.isNotEmpty)
                Text(
                  secondary,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherRow() {
    return Row(
      // Matches the start alignment _buildIconRow uses above, so this row's
      // icon sits at the same relative position against its text as the
      // location/date rows' icons do against theirs.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(weather?.icon ?? Icons.wb_sunny, color: Colors.black54, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: isLoadingWeather
              ? Row(
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Loading weather...",
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                  ],
                )
              : Text(
                  _formatWeather(weather),
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
        ),
      ],
    );
  }

  /// Formats as "26°C · Partly cloudy".
  String _formatWeather(WeatherSnapshot? weather) {
    if (weather == null) return 'Weather unavailable';
    final temperature = weather.temperatureCelsius.round();
    return '$temperature°C · ${weather.description}';
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
