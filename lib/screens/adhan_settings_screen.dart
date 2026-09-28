import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/adhan_settings_provider.dart';
import '../providers/reminder_settings_provider.dart';
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
    final reminderProvider = Provider.of<ReminderSettingsProvider>(context);

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
            _buildPrayerNotificationsSection(context, provider, reminderProvider),
            const SizedBox(height: 24),
            _buildRemindersSection(context, reminderProvider),
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

  Widget _buildPrayerNotificationsSection(
    BuildContext context,
    AdhanSettingsProvider provider,
    ReminderSettingsProvider reminderProvider,
  ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final sunriseEnabled = reminderProvider.settings.sunriseMakruhEnabled;
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
          ...provider.notificationSettings.entries.expand((entry) {
            final tile = SwitchListTile(
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

            // Sunrise has no adhan, so it isn't part of AdhanSettingsProvider's
            // per-prayer map - but it's the notification users look for right
            // here, next to Fajr. Surface it backed by the reminder settings
            // (the makruh-window notification) instead of a no-op toggle.
            if (entry.key != 'Fajr') return [tile];
            return [
              tile,
              SwitchListTile(
                title: Text('Sunrise', style: TextStyle(color: onSurface)),
                subtitle: Text(
                  sunriseEnabled
                      ? 'Reminder will be sent (no adhan for sunrise)'
                      : 'No notification',
                  style: TextStyle(
                    color: sunriseEnabled ? Colors.green : onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                value: sunriseEnabled,
                onChanged: (value) => reminderProvider.setSunriseMakruh(enabled: value),
                contentPadding: EdgeInsets.zero,
              ),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildRemindersSection(BuildContext context, ReminderSettingsProvider provider) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final s = provider.settings;

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
              Icon(Icons.access_alarm, color: onSurface, size: 20),
              const SizedBox(width: 8),
              Text(
                'Prayer Reminders',
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
            'Makruh time windows and a nightly Surah Al-Mulk nudge',
            style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildReminderToggleRow(
            context,
            title: 'Fajr ending soon',
            description: (m) => 'Warns $m min before sunrise so you don\'t miss Fajr',
            enabled: s.fajrEndingEnabled,
            minutes: s.fajrEndingMinutesBefore,
            min: 5,
            max: 30,
            onToggle: (v) => provider.setFajrEnding(enabled: v),
            onMinutes: (v) => provider.setFajrEnding(minutesBefore: v),
          ),
          _buildReminderToggleRow(
            context,
            title: 'Sunrise makruh window',
            description: (m) => 'At sunrise, tells you to wait $m min before praying',
            enabled: s.sunriseMakruhEnabled,
            minutes: s.sunriseMakruhDurationMinutes,
            min: 10,
            max: 30,
            onToggle: (v) => provider.setSunriseMakruh(enabled: v),
            onMinutes: (v) => provider.setSunriseMakruh(durationMinutes: v),
          ),
          _buildReminderToggleRow(
            context,
            title: 'Dhuhr makruh window',
            description: (m) => 'Warns $m min before Dhuhr to avoid nafl at zawal',
            enabled: s.dhuhrMakruhEnabled,
            minutes: s.dhuhrMakruhMinutesBefore,
            min: 10,
            max: 60,
            onToggle: (v) => provider.setDhuhrMakruh(enabled: v),
            onMinutes: (v) => provider.setDhuhrMakruh(minutesBefore: v),
          ),
          _buildReminderToggleRow(
            context,
            title: 'Sunset makruh window',
            description: (m) => 'Warns $m min before Maghrib to avoid prayer',
            enabled: s.sunsetMakruhEnabled,
            minutes: s.sunsetMakruhMinutesBefore,
            min: 10,
            max: 30,
            onToggle: (v) => provider.setSunsetMakruh(enabled: v),
            onMinutes: (v) => provider.setSunsetMakruh(minutesBefore: v),
          ),
          _buildReminderToggleRow(
            context,
            title: 'Surah Al-Mulk reminder',
            description: (m) => 'Nudges you $m min after Isha to recite before sleeping',
            enabled: s.surahMulkEnabled,
            minutes: s.surahMulkDelayAfterIshaMinutes,
            min: 0,
            max: 90,
            isLast: true,
            onToggle: (v) => provider.setSurahMulk(enabled: v),
            onMinutes: (v) => provider.setSurahMulk(delayMinutes: v),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderToggleRow(
    BuildContext context, {
    required String title,
    required String Function(int minutes) description,
    required bool enabled,
    required int minutes,
    required int min,
    required int max,
    required ValueChanged<bool> onToggle,
    required ValueChanged<int> onMinutes,
    bool isLast = false,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 4),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: onSurface.withValues(alpha: 0.08))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text(title, style: TextStyle(color: onSurface)),
            subtitle: Text(
              description(minutes),
              style: TextStyle(
                color: enabled ? Colors.teal : onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            value: enabled,
            onChanged: onToggle,
            contentPadding: EdgeInsets.zero,
          ),
          if (enabled)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$min',
                      style: TextStyle(fontSize: 11, color: onSurface.withValues(alpha: 0.5)),
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.teal,
                        inactiveTrackColor: onSurface.withValues(alpha: 0.15),
                        thumbColor: Colors.teal,
                        overlayColor: Colors.teal.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: minutes.toDouble(),
                        min: min.toDouble(),
                        max: max.toDouble(),
                        divisions: max - min,
                        label: '$minutes min',
                        onChanged: (v) => onMinutes(v.round()),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$max',
                      style: TextStyle(fontSize: 11, color: onSurface.withValues(alpha: 0.5)),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
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
