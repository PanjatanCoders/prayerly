import 'package:flutter/material.dart';
import 'package:prayerly/models/dhikr_tracking_models.dart';
import 'package:prayerly/services/dhikr_storage_service.dart';
import 'package:prayerly/utils/theme/app_theme.dart';
import 'package:prayerly/utils/theme/app_transitions.dart';
import 'package:prayerly/widgets/dhikar/add_custom_dhikr_dialog.dart';
import 'package:prayerly/widgets/dhikar/dhikr_text_widget.dart';
import 'dhikr_counter_screen.dart';

/// User-created custom dhikr (name + target count). Extracted from the old
/// selection screen's "My Tasbih" tab.
class MyTasbihScreen extends StatefulWidget {
  const MyTasbihScreen({super.key});

  @override
  State<MyTasbihScreen> createState() => _MyTasbihScreenState();
}

class _MyTasbihScreenState extends State<MyTasbihScreen> {
  List<CustomDhikr> _customDhikr = [];

  @override
  void initState() {
    super.initState();
    _loadCustomDhikr();
  }

  Future<void> _loadCustomDhikr() async {
    final list = await DhikrStorageService.getCustomDhikrList();
    if (!mounted) return;
    setState(() => _customDhikr = list);
  }

  Future<void> _addCustomDhikr() async {
    await showDialog(
      context: context,
      builder: (context) => AddCustomDhikrDialog(
        onCreate: (dhikr) async {
          await DhikrStorageService.addCustomDhikr(dhikr);
          await _loadCustomDhikr();
        },
      ),
    );
  }

  Future<void> _deleteCustomDhikr(CustomDhikr dhikr) async {
    await DhikrStorageService.deleteCustomDhikr(dhikr.id);
    await _loadCustomDhikr();
  }

  Future<bool> _confirmDeleteCustomDhikr(CustomDhikr dhikr) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tasbih?'),
        content: Text('Remove "${dhikr.transliteration}" from your tasbih list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _openDhikrCounter(CustomDhikr dhikr) {
    Navigator.push(context, AppTransitions.slideIn(DhikrCounterScreen(dhikr: dhikr)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('My Tasbih')),
      body: _customDhikr.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No custom tasbih yet',
                      style: AppTheme.subheadingStyle(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Add Tasbih" to create your own dhikr with a custom name and target count.',
                      textAlign: TextAlign.center,
                      style: AppTheme.captionStyle(context),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              itemCount: _customDhikr.length,
              itemBuilder: (context, index) {
                final dhikr = _customDhikr[index];
                return Dismissible(
                  key: ValueKey(dhikr.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _confirmDeleteCustomDhikr(dhikr),
                  onDismissed: (_) => _deleteCustomDhikr(dhikr),
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  child: DhikrCardWidget(
                    dhikr: dhikr,
                    onTap: () => _openDhikrCounter(dhikr),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCustomDhikr,
        icon: const Icon(Icons.add),
        label: const Text('Add Tasbih'),
        backgroundColor: AppTheme.islamicColors['dhikr'],
        foregroundColor: AppTheme.white,
      ),
    );
  }
}
