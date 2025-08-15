// screens/dhikr_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:prayerly/models/dhikr_models.dart';
import 'package:prayerly/services/dhikr_data_service.dart';
import 'package:prayerly/services/dhikr_service.dart';
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Dhikr Counter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
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
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search dhikr...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
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
        backgroundColor: Colors.white,
        selectedColor: category?.color.withValues(alpha: 0.2) ?? Colors.grey.shade200,
        checkmarkColor: category?.color ?? Colors.grey.shade600,
        labelStyle: TextStyle(
          color: isSelected 
            ? (category?.color ?? Colors.grey.shade700) 
            : Colors.grey.shade600,
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No dhikr found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            Text(
              'Try adjusting your search or filter',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Text('${dhikrList.length} dhikr available'),
        children: dhikrList.map((dhikr) => 
          ListTile(
            title: Text(dhikr.transliteration),
            subtitle: Text(dhikr.translation),
            trailing: Text('${dhikr.targetCount}x'),
            onTap: () => _openDhikrCounter(dhikr),
          ),
        ).toList(),
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
          colors: [Colors.amber.shade100, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                '$timeOfDay Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
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