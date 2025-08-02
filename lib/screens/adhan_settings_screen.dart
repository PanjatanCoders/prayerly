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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Adhan Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVolumeSection(context, provider),
            const SizedBox(height: 24),
            _buildAdhanTypeSection(provider),
            const SizedBox(height: 24),
            _buildPrayerNotificationsSection(provider),
            const SizedBox(height: 24),
            _buildTestSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSection(
    BuildContext context,
    AdhanSettingsProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Adhan Volume',
                style: TextStyle(
                  color: Colors.white,
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
              inactiveTrackColor: Colors.grey[700],
              thumbColor: Colors.amber,
              overlayColor: Colors.amber.withOpacity(0.2),
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

  Widget _buildAdhanTypeSection(AdhanSettingsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.music_note, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Adhan Style',
                style: TextStyle(
                  color: Colors.white,
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
                style: const TextStyle(color: Colors.white),
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

  Widget _buildPrayerNotificationsSection(AdhanSettingsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Prayer Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose which prayers should play adhan',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ...provider.notificationSettings.entries.map((entry) {
            return SwitchListTile(
              title: Text(
                entry.key,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                entry.value ? 'Adhan will play' : 'Silent notification only',
                style: TextStyle(
                  color: entry.value ? Colors.green : Colors.grey,
                  fontSize: 12,
                ),
              ),
              value: entry.value,
              onChanged: (value) {
                provider.toggleNotification(entry.key, value);
              },
              activeColor: Colors.amber,
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTestSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Test Adhan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Test the selected adhan with current volume settings',
            style: TextStyle(color: Colors.grey, fontSize: 12),
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
