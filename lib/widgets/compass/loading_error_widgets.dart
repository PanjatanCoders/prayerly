// widgets/compass/loading_error_widgets.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../l10n/app_localizations.dart';
import '../../services/qibla_service.dart';

/// Shown while the first location fix is being resolved.
class QiblaLoadingWidget extends StatelessWidget {
  final String? message;

  const QiblaLoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            message ?? AppLocalizations.of(context)!.qiblaCompass,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state driven by a typed [QiblaFailure] rather than by string-matching
/// an exception message, so each cause gets the action that actually fixes it.
class QiblaErrorWidget extends StatelessWidget {
  final QiblaFailure failure;
  final VoidCallback onRetry;

  const QiblaErrorWidget({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final (String title, String body, IconData icon) = switch (failure) {
      QiblaFailure.locationPermissionDenied => (
          l10n.locationPermissionRequired,
          l10n.locationPermissionRequiredHint,
          Icons.location_disabled,
        ),
      QiblaFailure.locationPermissionDeniedForever => (
          l10n.locationPermissionBlocked,
          l10n.locationPermissionBlockedHint,
          Icons.lock_outline,
        ),
      QiblaFailure.locationUnavailable => (
          l10n.locationUnavailable,
          l10n.locationUnavailableHint,
          Icons.location_off,
        ),
      QiblaFailure.compassUnavailable => (
          l10n.compassUnavailable,
          l10n.compassUnavailableHint,
          Icons.explore_off,
        ),
    };

    final showSettings =
        failure == QiblaFailure.locationPermissionDeniedForever;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (showSettings)
              FilledButton.icon(
                onPressed: Geolocator.openAppSettings,
                icon: const Icon(Icons.settings),
                label: Text(l10n.openSettings),
              )
            else
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.tryAgain),
              ),
          ],
        ),
      ),
    );
  }
}

/// Inline notice for devices with no magnetometer.
///
/// The bearing and distance are still correct without a sensor, so this is a
/// banner above working content rather than a full-screen failure.
class CompassUnavailableBanner extends StatelessWidget {
  const CompassUnavailableBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.explore_off,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.compassUnavailable,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.compassUnavailableHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
