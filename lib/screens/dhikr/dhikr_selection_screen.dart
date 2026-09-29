import 'package:flutter/material.dart';
import 'package:prayerly/models/dhikr_models.dart';
import 'package:prayerly/services/dhikr_service.dart';
import 'package:prayerly/services/dhikr_storage_service.dart';
import 'package:prayerly/utils/theme/app_theme.dart';
import 'package:prayerly/utils/theme/app_transitions.dart';
import 'package:prayerly/widgets/prayer_times/glass_sidebar.dart';
import 'package:prayerly/widgets/prayer_times/info_dialog_widget.dart';
import 'all_dhikr_screen.dart';
import 'dhikr_categories_screen.dart';
import 'dhikr_counter_screen.dart';
import 'my_tasbih_screen.dart';

/// Dhikr home screen: a hero header, time-of-day filter chips, a "Today's
/// Dhikr" highlight, real activity stats, and a browsable list - all reading
/// from the same dhikr data/services the rest of the feature already used.
/// Tapping any dhikr still opens the dedicated [DhikrCounterScreen] to do
/// the actual counting, rather than counting inline on this screen.
class DhikrSelectionScreen extends StatefulWidget {
  const DhikrSelectionScreen({super.key});

  @override
  State<DhikrSelectionScreen> createState() => _DhikrSelectionScreenState();
}

class _DhikrSelectionScreenState extends State<DhikrSelectionScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DhikrTimeGroup _selectedGroup = DhikrTimeGroup.daily;
  ({int today, int thisWeek, int weeklyGoal})? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await DhikrStorageService.getStatsSummary();
    if (mounted) setState(() => _stats = stats);
  }

  void _openDhikrCounter(Dhikr dhikr) {
    Navigator.push(
      context,
      AppTransitions.slideIn(DhikrCounterScreen(dhikr: dhikr)),
    ).then((_) => _loadStats());
  }

  Future<void> _editWeeklyGoal() async {
    final controller = TextEditingController(
      text: (_stats?.weeklyGoal ?? 1000).toString(),
    );
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weekly Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Target recitations per week'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      await DhikrStorageService.setWeeklyGoal(result);
      _loadStats();
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => const InfoDialogWidget(
        locationData: null,
        prayerTimesData: null,
        elevation: null,
        notificationsEnabled: false,
        onToggleNotifications: _noop,
      ),
    );
  }

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final dhikrColor = AppTheme.islamicColors['dhikr']!;
    final dhikrList = DhikrService.getDhikrForTimeGroup(_selectedGroup);
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final todaysDhikr = dhikrList.isEmpty ? null : dhikrList[dayOfYear % dhikrList.length];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Icon(Icons.menu, color: onSurface),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mosque, color: onSurface, size: 22),
            const SizedBox(width: 8),
            Text(
              'Prayerly',
              style: TextStyle(color: onSurface, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<VoidCallback>(
            icon: Icon(Icons.more_vert, color: onSurface),
            onSelected: (action) => action(),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: () => Navigator.push(context, AppTransitions.slideIn(const DhikrCategoriesScreen())),
                child: const Text('Categories'),
              ),
              PopupMenuItem(
                value: () => Navigator.push(context, AppTransitions.slideIn(const MyTasbihScreen())),
                child: const Text('My Tasbih'),
              ),
            ],
          ),
        ],
      ),
      drawer: GlassSidebar(onShowInfo: _showInfoDialog),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroHeader(dhikrColor: dhikrColor),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterChips(dhikrColor),
                  const SizedBox(height: 20),
                  if (todaysDhikr != null)
                    _TodaysDhikrCard(
                      dhikr: todaysDhikr,
                      dhikrColor: dhikrColor,
                      onTap: () => _openDhikrCounter(todaysDhikr),
                    ),
                  const SizedBox(height: 16),
                  _buildStatsRow(onSurface),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedGroup == DhikrTimeGroup.daily
                            ? 'Popular Dhikr'
                            : '${_selectedGroup.label} Dhikr',
                        style: AppTheme.subheadingStyle(context).copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(context, AppTransitions.slideIn(const AllDhikrScreen())),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('View All'),
                            Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ...dhikrList.map(
                    (dhikr) => _DhikrListRow(
                      dhikr: dhikr,
                      onTap: () => _openDhikrCounter(dhikr),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(Color dhikrColor) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...DhikrTimeGroup.values.map(
            (group) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(group.label),
                selected: _selectedGroup == group,
                onSelected: (_) => setState(() => _selectedGroup = group),
                selectedColor: dhikrColor,
                labelStyle: TextStyle(
                  color: _selectedGroup == group ? Colors.white : null,
                  fontWeight: _selectedGroup == group ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
          ActionChip(
            label: const Text('All'),
            onPressed: () => Navigator.push(context, AppTransitions.slideIn(const AllDhikrScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Color onSurface) {
    final stats = _stats;
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.bar_chart,
            iconColor: AppTheme.primaryGreen,
            label: 'Today',
            value: stats == null ? '—' : '${stats.today}',
            sublabel: 'Total Dhikr',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.calendar_month,
            iconColor: AppTheme.primaryAmber,
            label: 'This Week',
            value: stats == null ? '—' : '${stats.thisWeek}',
            sublabel: 'Total Dhikr',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.flag,
            iconColor: Colors.deepPurple,
            label: 'My Goal',
            value: stats == null ? '—' : '${stats.weeklyGoal}',
            sublabel: 'Per Week',
            onTap: _editWeeklyGoal,
          ),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final Color dhikrColor;

  const _HeroHeader({required this.dhikrColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/hero_prayer_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dhikr',
              style: TextStyle(
                color: dhikrColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Remember Allah, find peace.',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 14),
            const Text(
              '"Verily, in the remembrance of Allah do hearts find rest."',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "— Qur'an 13:28",
              style: TextStyle(color: Colors.black.withValues(alpha: 0.55), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaysDhikrCard extends StatelessWidget {
  final Dhikr dhikr;
  final Color dhikrColor;
  final VoidCallback onTap;

  const _TodaysDhikrCard({
    required this.dhikr,
    required this.dhikrColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book, color: dhikrColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Dhikr",
                          style: TextStyle(color: onSurface, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          dhikr.meaning,
                          style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: onSurface.withValues(alpha: 0.4)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: dhikrColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      dhikr.arabic,
                      style: TextStyle(color: dhikrColor, fontSize: 30, fontWeight: FontWeight.w600),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      dhikr.transliteration,
                      style: TextStyle(color: onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dhikr.translation,
                      style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Target: ${dhikr.targetCount} • Tap to start counting',
                style: TextStyle(color: onSurface.withValues(alpha: 0.5), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String sublabel;
  final VoidCallback? onTap;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sublabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(color: onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: onSurface, fontSize: 11, fontWeight: FontWeight.w600)),
              Text(sublabel, style: TextStyle(color: onSurface.withValues(alpha: 0.5), fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DhikrListRow extends StatelessWidget {
  final Dhikr dhikr;
  final VoidCallback onTap;

  const _DhikrListRow({required this.dhikr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: dhikr.category.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  String.fromCharCode(dhikr.arabic.runes.first),
                  style: TextStyle(
                    color: AppTheme.legibleAccent(context, dhikr.category.color),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dhikr.transliteration,
                      style: TextStyle(color: onSurface, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      dhikr.translation,
                      style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${dhikr.targetCount}', style: TextStyle(color: onSurface, fontSize: 12)),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: onSurface.withValues(alpha: 0.4), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
