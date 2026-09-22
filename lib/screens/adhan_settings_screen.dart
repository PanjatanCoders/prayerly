import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/adhan_settings_provider.dart';
import '../services/adhan_service.dart';

class AdhanSettingsScreen extends StatelessWidget {
  const AdhanSettingsScreen({super.key});

  void _testAdhan(BuildContext context) {
    AdhanService.testAdhan();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playing test adhan (10 seconds)...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdhanSettingsProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Adhan Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAutoPlaySection(context, provider),
            const SizedBox(height: 24),
            _buildVolumeSection(context, provider),
            const SizedBox(height: 24),
            _buildAdhanTypeSection(context, provider),
            const SizedBox(height: 24),
            _buildPrayerNotificationsSection(context, provider),
            const SizedBox(height: 24),
            _buildTestSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoPlaySection(BuildContext context, AdhanSettingsProvider provider) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_fill, color: onSurface, size: 20),
              const SizedBox(width: 8),
              Text(
                'Auto-Play Settings',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(
              'Auto-play Adhan',
              style: TextStyle(color: onSurface),
            ),
            subtitle: Text(
              provider.autoPlayEnabled
                  ? 'Adhan will play automatically when prayer time arrives'
                  : 'Tap notification to play adhan manually',
              style: TextStyle(
                color: provider.autoPlayEnabled ? Colors.green : onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            value: provider.autoPlayEnabled,
            onChanged: (value) {
              provider.setAutoPlayEnabled(value);
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSection(
    BuildContext context,
    AdhanSettingsProvider provider,
  ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.volume_up, color: onSurface, size: 20),
              const SizedBox(width: 8),
              Text(
                'Adhan Volume',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(provider.volume * 100).round()}%',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.amber,
              inactiveTrackColor: onSurface.withValues(alpha: 0.15),
              thumbColor: Colors.amber,
              overlayColor: Colors.amber.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: provider.volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (value) => provider.setVolume(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdhanTypeSection(BuildContext context, AdhanSettingsProvider provider) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.music_note, color: onSurface, size: 20),
              const SizedBox(width: 8),
              Text(
                'Adhan Style',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...AdhanService.adhanTypes.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(
                entry.value,
                style: TextStyle(color: onSurface),
              ),
              value: entry.key,
              groupValue: provider.adhanType,
              onChanged: (value) {
                if (value != null) {
                  provider.setAdhanType(value);
                }
              },
              activeColor: Colors.amber,
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPrayerNotificationsSection(BuildContext context, AdhanSettingsProvider provider) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications, color: onSurface, size: 20),
              const SizedBox(width: 8),
              Text(
                'Prayer Notifications',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            provider.autoPlayEnabled
                ? 'Choose which prayers should automatically play adhan'
                : 'Choose which prayers should send notifications',
            style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 12),
          ),
          const SizedBox(height: 16),
          ...provider.notificationSettings.entries.map((entry) {
            return SwitchListTile(
              title: Text(
                entry.key,
                style: TextStyle(color: onSurface),
              ),
              subtitle: Text(
                entry.value
                    ? (provider.autoPlayEnabled
                        ? 'Adhan will play automatically'
                        : 'Notification will be sent')
                    : 'No notification',
                style: TextStyle(
                  color: entry.value ? Colors.green : onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              value: entry.value,
              onChanged: (value) {
                provider.toggleNotification(entry.key, value);
              },
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTestSection(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle, color: onSurface, size: 20),
              const SizedBox(width: 8),
              Text(
                'Test Adhan',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Test the selected adhan with current volume settings',
            style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _testAdhan(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Test Adhan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
