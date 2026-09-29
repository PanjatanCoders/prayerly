// widgets/prayer_times/glass_sidebar.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:prayerly/screens/calendar/prayer_calendar_screen.dart';
import 'package:prayerly/screens/dhikr/dhikr_selection_screen.dart';
import 'package:prayerly/utils/theme/app_transitions.dart';
import '../../screens/qaza/qaza_tracker_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/zakat/zakat_screen.dart';

/// App navigation sidebar with a glassmorphism treatment: a blurred,
/// translucent panel over whatever is behind the open drawer, with soft
/// glass "cards" for each destination. Works as a standard [Scaffold.drawer]
/// (opened via [ScaffoldState.openDrawer]) so it slides in from the left
/// with the normal scrim and swipe-to-dismiss behavior.
class GlassSidebar extends StatelessWidget {
  /// Opens the app-info dialog that used to live behind a dedicated AppBar
  /// button; it moved here once that button was removed as redundant with
  /// the bottom nav bar.
  final VoidCallback onShowInfo;

  const GlassSidebar({super.key, required this.onShowInfo});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Tuned so text/icons stay legible over any content behind the blur,
    // in both themes, without turning fully opaque (which would defeat the
    // glass effect).
    final glassFillAlpha = isDark ? 0.45 : 0.55;
    final glassFill = isDark
        ? Colors.black.withValues(alpha: glassFillAlpha)
        : Colors.white.withValues(alpha: glassFillAlpha);
    final glassBorder = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.6);

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 300,
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: glassBorder, width: 1),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  glassFill,
                  (isDark ? Colors.black : Colors.white)
                      .withValues(alpha: glassFillAlpha * 0.7),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, onSurface, isDark),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _GlassMenuTile(
                          icon: Icons.format_list_numbered,
                          iconColor: Colors.green,
                          title: 'Qaza Tracker',
                          subtitle: 'Track missed prayers',
                          onTap: () => _navigate(context, const QazaTrackerScreen()),
                        ),
                        _GlassMenuTile(
                          icon: Icons.volunteer_activism,
                          iconColor: Colors.teal,
                          title: 'Zakat Calculator',
                          subtitle: 'Calculate & track Zakat',
                          onTap: () => _navigate(context, const ZakatScreen()),
                        ),
                        _GlassMenuTile(
                          icon: Icons.circle_outlined,
                          iconColor: Colors.purple,
                          title: 'Dhikr Counter',
                          subtitle: 'Digital Tasbih counter',
                          onTap: () => _navigate(context, const DhikrSelectionScreen()),
                        ),
                        _GlassMenuTile(
                          icon: Icons.settings,
                          iconColor: Colors.blue,
                          title: 'Settings',
                          subtitle: 'Theme, language & adhan',
                          onTap: () => _navigate(context, const SettingsScreen()),
                        ),
                        _GlassMenuTile(
                          icon: Icons.calendar_month,
                          iconColor: Colors.orange,
                          title: 'Prayer Calendar',
                          subtitle: 'Monthly prayer times',
                          onTap: () => _navigate(context, const PrayerCalendarScreen()),
                        ),
                        _GlassMenuTile(
                          icon: Icons.info_outline,
                          iconColor: Colors.grey,
                          title: 'About Prayerly',
                          subtitle: 'App info & credits',
                          onTap: () {
                            Navigator.pop(context);
                            onShowInfo();
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildFooter(onSurface),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, AppTransitions.slideIn(screen));
  }

  Widget _buildHeader(BuildContext context, Color onSurface, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFFFFA000)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.mosque, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prayerly',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Your daily prayer companion',
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(Color onSurface) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Icon(Icons.favorite, size: 12, color: onSurface.withValues(alpha: 0.4)),
          const SizedBox(width: 6),
          Text(
            'Made with care, for the Ummah',
            style: TextStyle(color: onSurface.withValues(alpha: 0.4), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _GlassMenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GlassMenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: onSurface.withValues(alpha: 0.4),
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
