// widgets/prayer_times/loading_widget.dart
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final bool isLoadingLocation;

  const LoadingWidget({
    super.key,
    required this.isLoadingLocation,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            isLoadingLocation
                ? 'Getting your location...'
                : 'Loading prayer times...',
            style: TextStyle(color: onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            isLoadingLocation
                ? 'Please ensure location permissions are enabled'
                : 'Calculating prayer times for your location',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}