// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import '../services/qaza_service.dart';

class QazaStatisticsScreen extends StatefulWidget {
  const QazaStatisticsScreen({super.key});

  @override
  State<QazaStatisticsScreen> createState() => _QazaStatisticsScreenState();
}

class _QazaStatisticsScreenState extends State<QazaStatisticsScreen> {
  double _completionPercentage = 0;
  int _totalQaza = 0;
  QazaStreak? _streak;
  Map<String, int> _qazaCounts = {};
  List<QazaHistoryEntry> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final completion = await QazaService.getCompletionPercentage();
    final totalQaza = await QazaService.getTotalQazaCount();
    final streak = await QazaService.getStreak();
    final counts = await QazaService.getQazaCounts();
    final history = await QazaService.getQazaHistory();
    setState(() {
      _completionPercentage = completion;
      _totalQaza = totalQaza;
      _streak = streak;
      _qazaCounts = counts;
      _history = history;
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qaza Statistics', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall completion
                  _buildCompletionCard(),

                  const SizedBox(height: 28),

                  // Per prayer breakdown
                  Text('Breakdown By Prayer', style: _sectionHeaderStyle()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: QazaService.prayerTypes.map((prayer) {
                      final count = _qazaCounts[prayer] ?? 0;
                      return Chip(
                        label: Text('$prayer: $count', style: const TextStyle(color: Colors.white)),
                        backgroundColor: _getPrayerColor(prayer).withValues(alpha: 0.85),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // Streak section
                  Text('Consistency Streaks', style: _sectionHeaderStyle()),
                  const SizedBox(height: 6),
                  _streak == null
                      ? const Text('No streak data.', style: TextStyle(color: Colors.white54))
                      : Row(
                          children: [
                            _buildStreakBox('Current', _streak!.current, Colors.green),
                            const SizedBox(width: 16),
                            _buildStreakBox('Longest', _streak!.longest, Colors.orange),
                          ],
                        ),

                  const SizedBox(height: 28),

                  // Qaza Activity Summary
                  Text('Qaza Activity (last 7 days)', style: _sectionHeaderStyle()),
                  const SizedBox(height: 6),
                  _buildActivityBarChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Colors.green, size: 32),
              const SizedBox(width: 10),
              Text(
                '${_completionPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.green, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'completed (${_totalQaza} to go)',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _completionPercentage / 100,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBox(String label, int days, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('$days', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActivityBarChart() {
    final today = DateTime.now();
    // Prepare daily completed count for last 7 days
    List<int> completedPerDay = List.generate(7, (i) {
      final date = DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - i));
      return _history.where((entry) {
        if (entry.action != 'completed') return false;
        final entryDate = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
        return entryDate == date;
      }).fold(0, (sum, e) => sum + e.counts.values.fold(0, (a, b) => a + b));
    });

    int maxCompleted = completedPerDay.fold(0, (curr, v) => v > curr ? v : curr);
    if (maxCompleted == 0) maxCompleted = 1; // Prevent division by zero

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final dayName = _dayNameShort(today.subtract(Duration(days: 6 - i)));
          final completed = completedPerDay[i];
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 70 * completed / maxCompleted,
                  width: 16,
                  decoration: BoxDecoration(
                    color: completed > 0 ? Colors.green : Colors.grey[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dayName,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                Text(
                  completed.toString(),
                  style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _dayNameShort(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  TextStyle _sectionHeaderStyle() => const TextStyle(
        color: Colors.grey,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 3,
      );
}
