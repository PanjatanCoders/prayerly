// widgets/compass/qibla_info_widget.dart

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/location_data.dart';
import '../../models/qibla_data.dart';
import '../../services/compass_service.dart';
import '../../services/qibla_service.dart';

/// The primary read-out: how far the user still has to turn.
///
/// This replaces the old "Accuracy" tile, which reported perfect alignment at
/// a 180 degree offset - that is, while facing directly away from the Kaaba.
class QiblaGuidanceBanner extends StatelessWidget {
  final QiblaReading reading;

  const QiblaGuidanceBanner({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final turn = reading.turnAngle;
    final aligned = reading.isAligned;

    final String label;
    final IconData icon;
    if (turn == null) {
      label = l10n.waitingForCompass;
      icon = Icons.sensors;
    } else if (aligned) {
      label = l10n.facingQiblaNow;
      icon = Icons.check_circle;
    } else {
      final degrees = turn.abs().round().toString();
      label = turn > 0
          ? l10n.turnRightDegrees(degrees)
          : l10n.turnLeftDegrees(degrees);
      // Rotation icons rather than turn arrows: they read the same way
      // in LTR and RTL layouts.
      icon = turn > 0 ? Icons.rotate_right : Icons.rotate_left;
    }

    final background = aligned
        ? const Color(0xFF2E9E5B)
        : theme.colorScheme.surfaceContainerHighest;
    final foreground =
        aligned ? Colors.white : theme.colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: foreground, size: 24),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Supporting detail: bearing, heading, distance and sensor confidence.
class QiblaInfoWidget extends StatelessWidget {
  final QiblaReading reading;

  const QiblaInfoWidget({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final heading = reading.heading;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _Tile(
                    icon: Icons.explore,
                    label: l10n.finderTitle,
                    value:
                        '${reading.qiblaBearing.round()}° ${QiblaService.cardinalFor(reading.qiblaBearing)}',
                  ),
                ),
                Expanded(
                  child: _Tile(
                    icon: Icons.navigation,
                    label: l10n.heading,
                    value: heading == null
                        ? '—'
                        : '${heading.round()}° ${QiblaService.cardinalFor(heading)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _Tile(
                    icon: Icons.straighten,
                    label: l10n.distance,
                    value: _formatDistance(reading.distanceKm),
                  ),
                ),
                Expanded(
                  child: _Tile(
                    icon: Icons.gps_fixed,
                    label: l10n.alignment,
                    value: _accuracyLabel(l10n, reading.accuracy),
                    valueColor: _accuracyColor(theme, reading.accuracy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _LocationLine(location: reading.location),
            const SizedBox(height: 8),
            Text(
              l10n.magneticNorthNote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDistance(double km) {
    if (km < 10) return '${km.toStringAsFixed(1)} km';
    return '${km.round()} km';
  }

  static String _accuracyLabel(
    AppLocalizations l10n,
    CompassAccuracy accuracy,
  ) {
    switch (accuracy) {
      case CompassAccuracy.high:
        return l10n.accuracyHigh;
      case CompassAccuracy.medium:
        return l10n.accuracyMedium;
      case CompassAccuracy.low:
        return l10n.accuracyLow;
      case CompassAccuracy.unknown:
        return l10n.accuracyUnknown;
    }
  }

  static Color _accuracyColor(ThemeData theme, CompassAccuracy accuracy) {
    switch (accuracy) {
      case CompassAccuracy.high:
        return const Color(0xFF2E9E5B);
      case CompassAccuracy.medium:
        return const Color(0xFFEF8B23);
      case CompassAccuracy.low:
        return theme.colorScheme.error;
      case CompassAccuracy.unknown:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _Tile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            color: valueColor ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Names the position the bearing was calculated from, and flags it when that
/// position is not a live fix.
class _LocationLine extends StatelessWidget {
  final LocationData location;

  const _LocationLine({required this.location});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLive = location.isTrustworthy;

    final label = location.address.isNotEmpty
        ? location.address
        : location.formattedCoordinates;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isLive ? Icons.location_on : Icons.history,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            isLive ? label : '$label · ${l10n.savedLocation}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Shown only while the magnetometer reports a disturbed reading.
class CompassCalibrationBanner extends StatelessWidget {
  const CompassCalibrationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.rotate_90_degrees_ccw,
            size: 20,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.calibrationNeeded,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.calibrationHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
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
