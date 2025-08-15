import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prayerly/screens/qa_history_screen.dart';
import 'package:prayerly/screens/qaza_calculator_screen.dart';
import 'package:prayerly/screens/qaza_settings_screen.dart';
import 'package:prayerly/screens/qaza_statistics_screen.dart';
import 'package:prayerly/widgets/add_qaza_dialog.dart';
import 'package:prayerly/widgets/complete_qaza_dialog.dart';
// ignore: unused_import
import 'dart:math' as math;
import '../services/qaza_service.dart';

class QazaTrackerScreen extends StatefulWidget {
  const QazaTrackerScreen({super.key});

  @override
  State<QazaTrackerScreen> createState() => _QazaTrackerScreenState();
}

class _QazaTrackerScreenState extends State<QazaTrackerScreen>
    with TickerProviderStateMixin {
  Map<String, int> _qazaCounts = {};
  QazaStreak _streak = QazaStreak(current: 0, longest: 0);
  String _motivationalMessage = '';
  double _completionPercentage = 0.0;
  int _totalQaza = 0;
  Duration _estimatedCompletion = Duration.zero;
  bool _isLoading = true;

  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimationController.repeat(reverse: true);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final counts = await QazaService.getQazaCounts();
      final streak = await QazaService.getStreak();
      final message = await QazaService.getMotivationalMessage();
      final percentage = await QazaService.getCompletionPercentage();
      final total = await QazaService.getTotalQazaCount();
      final estimated = await QazaService.getEstimatedCompletionTime();

      setState(() {
        _qazaCounts = counts;
        _streak = streak;
        _motivationalMessage = message;
        _completionPercentage = percentage;
        _totalQaza = total;
        _estimatedCompletion = estimated;
        _isLoading = false;
      });

      _progressAnimationController.forward();
    } catch (e) {
      debugPrint('Error loading Qaza data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showAddQazaDialog() {
    showDialog(
      context: context,
      builder: (context) => AddQazaDialog(
        onAdd: (counts) async {
          await QazaService.addQazaPrayers(counts);
          _loadData();
          _showSnackBar('Qaza prayers added', Colors.orange);
        },
      ),
    );
  }

  void _showCompleteQazaDialog() {
    showDialog(
      context: context,
      builder: (context) => CompleteQazaDialog(
        currentCounts: _qazaCounts,
        onComplete: (counts) async {
          await QazaService.completeQazaPrayers(counts);
          _loadData();
          _showSnackBar('Alhamdulillah! Qaza prayers completed', Colors.green);
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  void _showQazaCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QazaCalculatorScreen()),
    );
  }

  void _showStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QazaStatisticsScreen()),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingScreen() : _buildMainContent(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Qaza Tracker',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calculate, color: Colors.white),
          onPressed: _showQazaCalculator,
          tooltip: 'Qaza Calculator',
        ),
        IconButton(
          icon: const Icon(Icons.analytics, color: Colors.white),
          onPressed: _showStatistics,
          tooltip: 'Statistics',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: Colors.grey[900],
          onSelected: (value) {
            switch (value) {
              case 'settings':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QazaSettingsScreen(),
                  ),
                );
                break;
              case 'history':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QazaHistoryScreen(),
                  ),
                );
                break;
              case 'export':
                _exportData();
                break;
              case 'import':
                _importData();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Settings', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.white),
                  SizedBox(width: 8),
                  Text('History', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Export Data', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'import',
              child: Row(
                children: [
                  Icon(Icons.upload, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Import Data', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Loading your Qaza tracker...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMotivationalHeader(),
          const SizedBox(height: 20),
          _buildProgressCard(),
          const SizedBox(height: 20),
          _buildStreakCard(),
          const SizedBox(height: 20),
          _buildQazaCountsGrid(),
          const SizedBox(height: 100), // Space for FABs
        ],
      ),
    );
  }

  Widget _buildMotivationalHeader() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withValues(alpha: 0.8),
                  Colors.teal.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.mosque, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text(
                  _motivationalMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_completionPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _getProgressColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: (_completionPercentage / 100) * _progressAnimation.value,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
                minHeight: 8,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressItem(
                'Total Qaza',
                _totalQaza.toString(),
                Icons.format_list_numbered,
              ),
              _buildProgressItem(
                'Estimated',
                _formatDuration(_estimatedCompletion),
                Icons.schedule,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.8),
            Colors.deepOrange.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Streak',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_streak.current} days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Longest: ${_streak.longest} days',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQazaCountsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prayer Counts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: QazaService.prayerTypes.length,
          itemBuilder: (context, index) {
            final prayer = QazaService.prayerTypes[index];
            final count = _qazaCounts[prayer] ?? 0;
            return _buildPrayerCard(prayer, count);
          },
        ),
      ],
    );
  }

  Widget _buildPrayerCard(String prayer, int count) {
    final color = _getPrayerColor(prayer);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: count > 0 ? color.withValues(alpha: 0.5) : Colors.grey[800]!,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getPrayerIcon(prayer),
            color: count > 0 ? color : Colors.grey[600],
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            prayer,
            style: TextStyle(
              color: count > 0 ? Colors.white : Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: count > 0 ? color : Colors.grey[600],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "complete",
          onPressed: _totalQaza > 0 ? _showCompleteQazaDialog : null,
          backgroundColor: Colors.green,
          child: const Icon(Icons.check, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "add",
          onPressed: _showAddQazaDialog,
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  Color _getProgressColor() {
    if (_completionPercentage >= 80) return Colors.green;
    if (_completionPercentage >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getPrayerColor(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Colors.blue;
      case 'Zuhr':
        return Colors.orange;
      case 'Asr':
        return Colors.amber;
      case 'Maghrib':
        return Colors.pink;
      case 'Isha':
        return Colors.purple;
      case 'Witr':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Zuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.wb_sunny_outlined;
      case 'Maghrib':
        return Icons.nights_stay;
      case 'Isha':
        return Icons.nightlight;
      case 'Witr':
        return Icons.star;
      default:
        return Icons.mosque;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else {
      return 'Today';
    }
  }

  Future<void> _exportData() async {
    try {
      final data = await QazaService.exportData();
      await Clipboard.setData(ClipboardData(text: data));
      _showSnackBar('Data copied to clipboard', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to export data', Colors.red);
    }
  }

  Future<void> _importData() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData?.text != null) {
        final success = await QazaService.importData(clipboardData!.text!);
        if (success) {
          _loadData();
          _showSnackBar('Data imported successfully', Colors.green);
        } else {
          _showSnackBar('Invalid data format', Colors.red);
        }
      }
    } catch (e) {
      _showSnackBar('Failed to import data', Colors.red);
    }
  }
}
