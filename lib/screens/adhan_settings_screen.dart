// screens/adhan_settings_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/adhan_service.dart';

class AdhanSettingsScreen extends StatefulWidget {
  const AdhanSettingsScreen({super.key});

  @override
  State<AdhanSettingsScreen> createState() => _AdhanSettingsScreenState();
}

class _AdhanSettingsScreenState extends State<AdhanSettingsScreen> {
  double _volume = 0.8;
  String _selectedAdhanType = 'makkah';
  Map<String, bool> _notificationSettings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final volume = await AdhanService.getAdhanVolume();
      final adhanType = await AdhanService.getSelectedAdhanType();
      final notifications = await AdhanService.getNotificationSettings();

      if (mounted) {
        setState(() {
          _volume = volume;
          _selectedAdhanType = adhanType;
          _notificationSettings = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveVolumeSettings(double volume) async {
    await AdhanService.setAdhanVolume(volume);
    setState(() {
      _volume = volume;
    });
  }

  Future<void> _saveAdhanType(String type) async {
    await AdhanService.setSelectedAdhanType(type);
    setState(() {
      _selectedAdhanType = type;
    });
  }

  Future<void> _togglePrayerNotification(String prayer, bool enabled) async {
    await AdhanService.updateNotificationSetting(prayer, enabled);
    setState(() {
      _notificationSettings[prayer] = enabled;
    });
  }

  void _testAdhan() {
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVolumeSection(),
                  const SizedBox(height: 24),
                  _buildAdhanTypeSection(),
                  const SizedBox(height: 24),
                  _buildPrayerNotificationsSection(),
                  const SizedBox(height: 24),
                  _buildTestSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildVolumeSection() {
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
                '${(_volume * 100).round()}%',
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
              value: _volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (value) {
                _saveVolumeSettings(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdhanTypeSection() {
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
              groupValue: _selectedAdhanType,
              onChanged: (value) {
                if (value != null) {
                  _saveAdhanType(value);
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

  Widget _buildPrayerNotificationsSection() {
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
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ..._notificationSettings.entries.map((entry) {
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
                _togglePrayerNotification(entry.key, value);
              },
              activeColor: Colors.amber,
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTestSection() {
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
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _testAdhan,
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