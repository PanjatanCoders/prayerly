import 'package:flutter/material.dart';
import 'package:prayerly/screens/calendar/prayer_calendar_screen.dart';
import 'package:prayerly/screens/islamic_events_screen.dart';
import 'package:prayerly/screens/settings_screen.dart';
import 'package:prayerly/screens/zakat/zakat_screen.dart';
import 'package:prayerly/utils/theme/app_theme.dart';
import 'package:prayerly/utils/theme/app_transitions.dart';

/// The "Other" bottom-nav tab: links to every page that doesn't have a tab of
/// its own.
class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, AppTransitions.slideIn(page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Other')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _OtherTile(
            icon: Icons.volunteer_activism,
            color: Colors.teal,
            title: 'Zakat Calculator',
            subtitle: 'Calculate & track Zakat',
            onTap: () => _open(context, const ZakatScreen()),
          ),
          _OtherTile(
            icon: Icons.calendar_month,
            color: Colors.orange,
            title: 'Prayer Calendar',
            subtitle: 'Monthly prayer times',
            onTap: () => _open(context, const PrayerCalendarScreen()),
          ),
          _OtherTile(
            icon: Icons.event,
            color: AppTheme.primaryAmber,
            title: 'Islamic Events',
            subtitle: 'Ashura, Eid, Ramadan & more',
            onTap: () => _open(context, const IslamicEventsScreen()),
          ),
          _OtherTile(
            icon: Icons.settings,
            color: Colors.blue,
            title: 'Settings',
            subtitle: 'Theme, language & adhan',
            onTap: () => _open(context, const SettingsScreen()),
          ),
        ],
      ),
    );
  }
}

class _OtherTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OtherTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
