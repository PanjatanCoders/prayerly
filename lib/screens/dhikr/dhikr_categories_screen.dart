import 'package:flutter/material.dart';
import 'package:prayerly/models/dhikr_models.dart';
import 'package:prayerly/services/dhikr_data_service.dart';
import 'package:prayerly/utils/bidi_utils.dart';
import 'package:prayerly/utils/theme/app_theme.dart';
import 'package:prayerly/utils/theme/app_transitions.dart';
import 'dhikr_counter_screen.dart';

/// Browse dhikr grouped by [DhikrCategory]. Extracted from the old selection
/// screen's "Categories" tab.
class DhikrCategoriesScreen extends StatelessWidget {
  const DhikrCategoriesScreen({super.key});

  void _openDhikrCounter(BuildContext context, Dhikr dhikr) {
    Navigator.push(
      context,
      AppTransitions.slideIn(DhikrCounterScreen(dhikr: dhikr)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = DhikrCategory.values;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Categories')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryDhikr = DhikrDataService.getDhikrByCategory(category);
          return _buildCategorySection(context, category, categoryDhikr);
        },
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    DhikrCategory category,
    List<Dhikr> dhikrList,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: AppTheme.cardDecoration(context),
        // The DecoratedBox above paints between here and the Card's own
        // Material, which otherwise swallows ExpansionTile's inner
        // ListTile ink splash (debug-mode assertion, not visually broken,
        // but cheap to fix properly since this file is being touched
        // anyway).
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            title: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.legibleAccent(context, category.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category.displayName,
                  style: AppTheme.bodyStyle(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle: Text(
              '${dhikrList.length} dhikr available',
              style: AppTheme.captionStyle(context),
            ),
            children: dhikrList
                .map(
                  (dhikr) => ListTile(
                    title: Text(
                      dhikr.transliteration,
                      style: AppTheme.bodyStyle(context),
                    ),
                    subtitle: Text(
                      dhikr.translation,
                      style: AppTheme.captionStyle(context),
                      textDirection: autoTextDirection(dhikr.translation),
                    ),
                    trailing: Text(
                      '${dhikr.targetCount}x',
                      style: AppTheme.bodyStyle(context).copyWith(
                        color: AppTheme.legibleAccent(context, category.color),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _openDhikrCounter(context, dhikr),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
