import 'package:flutter/material.dart';
import 'package:prayerly/models/dhikr_models.dart';
import 'package:prayerly/services/dhikr_data_service.dart';
import 'package:prayerly/utils/theme/app_theme.dart';
import 'package:prayerly/utils/theme/app_transitions.dart';
import 'package:prayerly/widgets/dhikar/dhikr_text_widget.dart';
import 'dhikr_counter_screen.dart';

/// Search + category browse across the full dhikr library. Extracted from
/// the old selection screen's "All Dhikr" tab so it still exists as a
/// destination, once the home screen ([DhikrSelectionScreen]) stopped being
/// tab-based.
class AllDhikrScreen extends StatefulWidget {
  const AllDhikrScreen({super.key});

  @override
  State<AllDhikrScreen> createState() => _AllDhikrScreenState();
}

class _AllDhikrScreenState extends State<AllDhikrScreen> {
  final List<Dhikr> _allDhikr = DhikrDataService.getAllDhikr();
  List<Dhikr> _filteredDhikr = [];
  DhikrCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredDhikr = _allDhikr;
  }

  void _filterDhikr() {
    setState(() {
      _filteredDhikr = _allDhikr.where((dhikr) {
        final matchesCategory =
            _selectedCategory == null || dhikr.category == _selectedCategory;
        final matchesSearch =
            _searchQuery.isEmpty ||
            dhikr.arabic.contains(_searchQuery) ||
            dhikr.transliteration.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            dhikr.translation.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _openDhikrCounter(Dhikr dhikr) {
    Navigator.push(context, AppTransitions.slideIn(DhikrCounterScreen(dhikr: dhikr)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('All Dhikr')),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _filteredDhikr.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No dhikr found',
                          style: AppTheme.subheadingStyle(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          'Try adjusting your search or filter',
                          style: AppTheme.captionStyle(context),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredDhikr.length,
                    itemBuilder: (context, index) {
                      final dhikr = _filteredDhikr[index];
                      return DhikrCardWidget(
                        dhikr: dhikr,
                        onTap: () => _openDhikrCounter(dhikr),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: TextField(
        style: AppTheme.bodyStyle(context),
        decoration: InputDecoration(
          hintText: 'Search dhikr...',
          hintStyle: AppTheme.bodyStyle(context).copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onChanged: (value) {
          _searchQuery = value;
          _filterDhikr();
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(null, 'All'),
          ...DhikrCategory.values.map(
            (category) => _buildCategoryChip(category, category.displayName.split(' ')[0]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(DhikrCategory? category, String label) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = selected ? category : null);
          _filterDhikr();
        },
        backgroundColor: Theme.of(context).cardColor,
        selectedColor:
            category?.color.withValues(alpha: 0.2) ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.legibleAccent(context, category?.color ?? Theme.of(context).colorScheme.primary),
        labelStyle: AppTheme.bodyStyle(context).copyWith(
          color: isSelected
              ? AppTheme.legibleAccent(context, category?.color ?? Theme.of(context).colorScheme.primary)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
