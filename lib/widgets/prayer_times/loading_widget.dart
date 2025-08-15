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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            isLoadingLocation
                ? 'Getting your location...'
                : 'Loading prayer times...',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            isLoadingLocation
                ? 'Please ensure location permissions are enabled'
                : 'Calculating prayer times for your location',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}