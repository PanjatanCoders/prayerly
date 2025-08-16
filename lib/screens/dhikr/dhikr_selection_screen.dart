import 'package:flutter/material.dart';
import 'package:prayerly/models/dhikr_models.dart';
import 'package:prayerly/services/dhikr_data_service.dart';
import 'package:prayerly/services/dhikr_service.dart';
import 'package:prayerly/utils/theme/app_theme.dart';
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
  late TabController _tabController;
  List<Dhikr> _allDhikr = [];
  List<Dhikr> _filteredDhikr = [];
  DhikrCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDhikr();
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

  void _filterDhikr() {
    setState(() {
      _filteredDhikr = _allDhikr.where((dhikr) {
        final matchesCategory = _selectedCategory == null || dhikr.category == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty ||
            dhikr.arabic.contains(_searchQuery) ||
            dhikr.transliteration.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            dhikr.translation.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _openDhikrCounter(Dhikr dhikr) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DhikrCounterScreen(dhikr: dhikr),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Dhikr Counter',
          style: AppTheme.subheadingStyle(context).copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.islamicColors['dhikr'],
        foregroundColor: AppTheme.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.white,
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Popular', icon: Icon(Icons.star)),
            Tab(text: 'All Dhikr', icon: Icon(Icons.list)),
            Tab(text: 'Categories', icon: Icon(Icons.category)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          
          // Category filter chips
          if (_tabController.index != 2) _buildCategoryFilter(),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPopularTab(),
                _buildAllDhikrTab(),
                _buildCategoriesTab(),
              ],
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
          ...DhikrCategory.values.map((category) => 
            _buildCategoryChip(category, category.displayName.split(' ')[0])),
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
        selectedColor: category?.color.withValues(alpha: 0.2) ?? 
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        checkmarkColor: category?.color ?? Theme.of(context).colorScheme.primary,
        labelStyle: AppTheme.bodyStyle(context).copyWith(
          color: isSelected 
            ? (category?.color ?? Theme.of(context).colorScheme.primary)
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
                  color: category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                category.displayName,
                style: AppTheme.bodyStyle(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          subtitle: Text(
            '${dhikrList.length} dhikr available',
            style: AppTheme.captionStyle(context),
          ),
          children: dhikrList.map((dhikr) => 
            ListTile(
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
                  color: category.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _openDhikrCounter(dhikr),
            ),
          ).toList(),
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
              Icon(
                Icons.wb_sunny,
                color: AppTheme.primaryAmber,
              ),
              const SizedBox(width: 8),
              Text(
                '$timeOfDay Recommendations',
                style: AppTheme.subheadingStyle(context).copyWith(
                  fontSize: 16,
                  color: AppTheme.primaryAmber,
                ),
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