import 'package:flutter/material.dart';
import 'package:prayerly/utils/theme/app_theme.dart';
import 'package:prayerly/utils/theme/app_transitions.dart';
import 'package:prayerly/widgets/theme_switch_widget.dart';
import '../services/language_service.dart';
import '../widgets/language_selector.dart';
import 'adhan_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          _buildSectionHeader(context, 'Language / भाषा / زبان / ভাষা'),
          const SizedBox(height: 8),
          _buildLanguageCard(context),

          const SizedBox(height: 24),

          // App Settings
          _buildSectionHeader(context, 'App Settings'),
          const SizedBox(height: 8),
          const ThemeSwitchWidget(showLabel: false),

          const SizedBox(height: 24),

          // Prayer Settings
          _buildSectionHeader(context, 'Prayer Settings'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            icon: Icons.volume_up,
            title: 'Adhan Sound & Notifications',
            subtitle: 'Configure call to prayer audio and reminders',
            onTap: () {
              Navigator.push(
                context,
                AppTransitions.slideIn(const AdhanSettingsScreen()),
              );
            },
          ),

          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            icon: Icons.location_on,
            title: 'Location',
            subtitle: 'Location is detected automatically for prayer times',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Location is resolved automatically from device GPS or last known fix.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: AppTheme.subheadingStyle(context).copyWith(
        color: AppTheme.legibleAccent(context, AppTheme.primaryGreen),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    return Card(
      child: Container(
        decoration: AppTheme.cardDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.language,
                    color: AppTheme.legibleAccent(context, AppTheme.primaryGreen),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Language',
                    style: AppTheme.bodyStyle(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ValueListenableBuilder<Locale>(
                valueListenable: LanguageService.localeNotifier,
                builder: (context, locale, child) {
                  return Text(
                    'Current: ${LanguageService.getLanguageName(locale)}',
                    style: AppTheme.captionStyle(context),
                  );
                },
              ),
              const SizedBox(height: 16),
              const LanguageSelector(showAsBottomSheet: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: Container(
        decoration: AppTheme.cardDecoration(context),
        child: ListTile(
          leading: Icon(icon, color: AppTheme.legibleAccent(context, AppTheme.primaryGreen)),
          title: Text(
            title,
            style: AppTheme.bodyStyle(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle, style: AppTheme.captionStyle(context)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
