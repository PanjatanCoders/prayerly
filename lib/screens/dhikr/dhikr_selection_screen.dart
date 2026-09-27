import 'package:flutter/material.dart';
import 'package:prayerly/models/dhikr_models.dart';
import 'package:prayerly/models/dhikr_tracking_models.dart';
import 'package:prayerly/services/dhikr_data_service.dart';
import 'package:prayerly/services/dhikr_service.dart';
import 'package:prayerly/services/dhikr_storage_service.dart';
import 'package:prayerly/utils/theme/app_theme.dart';
import 'package:prayerly/utils/theme/app_transitions.dart';
import 'package:prayerly/widgets/dhikar/add_custom_dhikr_dialog.dart';
import 'package:prayerly/widgets/dhikar/dhikr_text_widget.dart';
import 'dhikr_counter_screen.dart';

/// Main screen for selecting Dhikr to recite
class DhikrSelectionScreen extends StatefulWidget {
  const DhikrSelectionScreen({super.key});

  @override
  State<DhikrSelectionScreen> createState() => _DhikrSelectionScreenState();
}

class _DhikrSelectionScreenState extends State<DhikrSelectionScreen>
    with SingleTickerProviderStateMixin {
  static const _myTasbihTabIndex = 3;
  static const _categoriesTabIndex = 2;

  late TabController _tabController;
  List<Dhikr> _allDhikr = [];
  List<Dhikr> _filteredDhikr = [];
  List<CustomDhikr> _customDhikr = [];
  DhikrCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadDhikr();
    _loadCustomDhikr();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDhikr() {
    _allDhikr = DhikrDataService.getAllDhikr();
    _filteredDhikr = _allDhikr;
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
          if (mounted) _tabController.animateTo(_myTasbihTabIndex);
        },
      ),
    );
  }

  Future<void> _deleteCustomDhikr(CustomDhikr dhikr) async {
    await DhikrStorageService.deleteCustomDhikr(dhikr.id);
    await _loadCustomDhikr();
  }

  void _filterDhikr() {
    setState(() {
      _filteredDhikr = _allDhikr.where((dhikr) {
        final matchesCategory =
            _selectedCategory == null || dhikr.category == _selectedCategory;
        final matchesSearch =
            _searchQuery.isEmpty ||
            dhikr.arabic.contains(_searchQuery) ||
            dhikr.transliteration.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            dhikr.translation.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _openDhikrCounter(Dhikr dhikr) {
    Navigator.push(
      context,
      AppTransitions.slideIn(DhikrCounterScreen(dhikr: dhikr)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Dhikr Counter',
          style: AppTheme.subheadingStyle(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.legibleAccent(
            context,
            AppTheme.islamicColors['dhikr']!,
          ),
          labelColor: AppTheme.legibleAccent(
            context,
            AppTheme.islamicColors['dhikr']!,
          ),
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Popular', icon: Icon(Icons.star)),
            Tab(text: 'All Dhikr', icon: Icon(Icons.list)),
            Tab(text: 'Categories', icon: Icon(Icons.category)),
            Tab(text: 'My Tasbih', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar (only relevant when browsing the shared dhikr library)
          if (_tabController.index < _categoriesTabIndex) _buildSearchBar(),

          // Category filter chips
          if (_tabController.index < _categoriesTabIndex)
            _buildCategoryFilter(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPopularTab(),
                _buildAllDhikrTab(),
                _buildCategoriesTab(),
                _buildMyTasbihTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == _myTasbihTabIndex
          ? FloatingActionButton.extended(
              onPressed: _addCustomDhikr,
              icon: const Icon(Icons.add),
              label: const Text('Add Tasbih'),
              backgroundColor: AppTheme.islamicColors['dhikr'],
              foregroundColor: AppTheme.white,
            )
          : null,
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
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
            (category) => _buildCategoryChip(
              category,
              category.displayName.split(' ')[0],
            ),
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
          setState(() {
            _selectedCategory = selected ? category : null;
          });
          _filterDhikr();
        },
        backgroundColor: Theme.of(context).cardColor,
        selectedColor:
            category?.color.withValues(alpha: 0.2) ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.legibleAccent(
          context,
          category?.color ?? Theme.of(context).colorScheme.primary,
        ),
        labelStyle: AppTheme.bodyStyle(context).copyWith(
          color: isSelected
              ? AppTheme.legibleAccent(
                  context,
                  category?.color ?? Theme.of(context).colorScheme.primary,
                )
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPopularTab() {
    final popularDhikr = DhikrDataService.getPopularDhikr();

    return Column(
      children: [
        // Time-based recommendations
        _buildRecommendationsSection(),

        // Popular dhikr list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: popularDhikr.length,
            itemBuilder: (context, index) {
              final dhikr = popularDhikr[index];
              return DhikrCardWidget(
                dhikr: dhikr,
                onTap: () => _openDhikrCounter(dhikr),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllDhikrTab() {
    if (_filteredDhikr.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No dhikr found',
              style: AppTheme.subheadingStyle(context).copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Text(
              'Try adjusting your search or filter',
              style: AppTheme.captionStyle(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredDhikr.length,
      itemBuilder: (context, index) {
        final dhikr = _filteredDhikr[index];
        return DhikrCardWidget(
          dhikr: dhikr,
          onTap: () => _openDhikrCounter(dhikr),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    final categories = DhikrCategory.values;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryDhikr = DhikrDataService.getDhikrByCategory(category);

        return _buildCategorySection(category, categoryDhikr);
      },
    );
  }

  Widget _buildMyTasbihTab() {
    if (_customDhikr.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No custom tasbih yet',
                style: AppTheme.subheadingStyle(context).copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
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
      );
    }

    return ListView.builder(
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
    );
  }

  Future<bool> _confirmDeleteCustomDhikr(CustomDhikr dhikr) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tasbih?'),
        content: Text(
          'Remove "${dhikr.transliteration}" from your tasbih list?',
        ),
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

  Widget _buildCategorySection(DhikrCategory category, List<Dhikr> dhikrList) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),

      child: Container(
        decoration: AppTheme.cardDecoration(context),
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
                  ),
                  trailing: Text(
                    '${dhikr.targetCount}x',
                    style: AppTheme.bodyStyle(context).copyWith(
                      color: AppTheme.legibleAccent(context, category.color),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => _openDhikrCounter(dhikr),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final recommendations = DhikrService.getTimeBasedRecommendations();
    final timeOfDay = _getTimeOfDayString();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryAmber.withValues(alpha: 0.1),
            AppTheme.primaryOrange.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryAmber.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, color: AppTheme.primaryAmber),
              const SizedBox(width: 8),
              Text(
                '$timeOfDay Recommendations',
                style: AppTheme.subheadingStyle(
                  context,
                ).copyWith(fontSize: 16, color: AppTheme.primaryAmber),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final dhikr = recommendations[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: DhikrCardWidget(
                    dhikr: dhikr,
                    onTap: () => _openDhikrCounter(dhikr),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeOfDayString() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }
}
