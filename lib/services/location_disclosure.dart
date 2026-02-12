// services/location_disclosure.dart
// Google Play requires prominent disclosure before requesting location permission.
// This dialog must appear BEFORE the system permission dialog.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationDisclosure {
  static const String _consentKey = 'location_disclosure_accepted';

  /// Shows prominent disclosure dialog if user hasn't consented yet.
  /// Returns true if user consents, false if user declines.
  /// If already consented previously, returns true immediately.
  static Future<bool> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyAccepted = prefs.getBool(_consentKey) ?? false;

    if (alreadyAccepted) return true;

    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Location Access',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prayerly needs your approximate location to:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _DisclosureItem(
              icon: Icons.access_time,
              text: 'Calculate accurate prayer times for your area',
            ),
            SizedBox(height: 8),
            _DisclosureItem(
              icon: Icons.explore,
              text: 'Show Qibla direction from your location',
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),
            Text(
              'Your location is:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _DisclosureItem(
              icon: Icons.check_circle,
              text: 'Used only while the app is open',
              color: Colors.green,
            ),
            SizedBox(height: 8),
            _DisclosureItem(
              icon: Icons.check_circle,
              text: 'Never shared with third parties',
              color: Colors.green,
            ),
            SizedBox(height: 8),
            _DisclosureItem(
              icon: Icons.check_circle,
              text: 'Not tracked in the background',
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'You can deny location access and the app will use a default location instead.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No Thanks'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Allow Location'),
          ),
        ],
      ),
    );

    final consented = result == true;
    if (consented) {
      await prefs.setBool(_consentKey, true);
    }
    return consented;
  }
}

class _DisclosureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _DisclosureItem({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color ?? Colors.blue.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
