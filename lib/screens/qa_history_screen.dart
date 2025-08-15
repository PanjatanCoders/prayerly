import 'package:flutter/material.dart';
import '../services/qaza_service.dart';

class QazaHistoryScreen extends StatefulWidget {
  const QazaHistoryScreen({super.key});

  @override
  State<QazaHistoryScreen> createState() => _QazaHistoryScreenState();
}

class _QazaHistoryScreenState extends State<QazaHistoryScreen> {
  late Future<List<QazaHistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = QazaService.getQazaHistory();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'added':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'added':
        return Icons.add_circle_outline;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qaza History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<QazaHistoryEntry>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load history',
                style: TextStyle(color: Colors.red[400], fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No Qaza history available',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final history = snapshot.data!;
          // Sort descending by timestamp (most recent first)
          history.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              final entry = history[index];
              final dateString = _formatDate(entry.timestamp);
              final actionColor = _actionColor(entry.action);
              final actionIcon = _actionIcon(entry.action);

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: actionColor.withValues(alpha: 0.7), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(actionIcon, color: actionColor, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          entry.action.toUpperCase(),
                          style: TextStyle(color: actionColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Spacer(),
                        Text(dateString, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: entry.counts.entries.map((e) {
                        if (e.value <= 0) return const SizedBox.shrink();
                        return _buildCountChip(e.key, e.value);
                      }).where((widget) => widget is! SizedBox).toList(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCountChip(String prayer, int count) {
    final color = _getPrayerColor(prayer);
    return Chip(
      label: Text('$prayer: $count', style: const TextStyle(color: Colors.white)),
      backgroundColor: color.withValues(alpha: 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
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
}
