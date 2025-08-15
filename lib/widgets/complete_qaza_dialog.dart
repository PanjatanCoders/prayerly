// widgets/complete_qaza_dialog.dart
// ignore_for_file: use_build_context_synchronously, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/qaza_service.dart';

class CompleteQazaDialog extends StatefulWidget {
  final Map<String, int> currentCounts;
  final Function(Map<String, int>) onComplete;

  const CompleteQazaDialog({
    super.key,
    required this.currentCounts,
    required this.onComplete,
  });

  @override
  State<CompleteQazaDialog> createState() => _CompleteQazaDialogState();
}

class _CompleteQazaDialogState extends State<CompleteQazaDialog>
    with TickerProviderStateMixin {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, int> _counts = {};
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    for (String prayer in QazaService.prayerTypes) {
      _controllers[prayer] = TextEditingController();
      _counts[prayer] = 0;
    }

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _celebrationController.dispose();
    super.dispose();
  }

  void _updateCount(String prayer, String value) {
    setState(() {
      final inputValue = int.tryParse(value) ?? 0;
      final maxAllowed = widget.currentCounts[prayer] ?? 0;
      _counts[prayer] = inputValue > maxAllowed ? maxAllowed : inputValue;
      if (_counts[prayer] != inputValue) {
        _controllers[prayer]!.text = _counts[prayer].toString();
      }
    });
  }

  void _incrementCount(String prayer) {
    setState(() {
      final current = _counts[prayer] ?? 0;
      final maxAllowed = widget.currentCounts[prayer] ?? 0;
      if (current < maxAllowed) {
        _counts[prayer] = current + 1;
        _controllers[prayer]!.text = _counts[prayer].toString();
      }
    });
    HapticFeedback.lightImpact();
  }

  void _decrementCount(String prayer) {
    setState(() {
      final current = _counts[prayer] ?? 0;
      if (current > 0) {
        _counts[prayer] = current - 1;
        _controllers[prayer]!.text = _counts[prayer].toString();
      }
    });
    HapticFeedback.lightImpact();
  }

  void _setMaxCount(String prayer) {
    setState(() {
      _counts[prayer] = widget.currentCounts[prayer] ?? 0;
      _controllers[prayer]!.text = _counts[prayer].toString();
    });
    HapticFeedback.mediumImpact();
  }

  bool get _hasValidInput {
    return _counts.values.any((count) => count > 0);
  }

  int get _totalToComplete {
    return _counts.values.fold(0, (sum, count) => sum + count);
  }

  void _onComplete() {
    if (_hasValidInput) {
      _celebrationController.forward();
      
      final nonZeroCounts = <String, int>{};
      _counts.forEach((prayer, count) {
        if (count > 0) {
          nonZeroCounts[prayer] = count;
        }
      });
      
      // Delay to show celebration animation
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onComplete(nonZeroCounts);
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Complete Qaza Prayers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter the number of prayers you have completed',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...QazaService.prayerTypes
                      .where((prayer) => (widget.currentCounts[prayer] ?? 0) > 0)
                      .map((prayer) => _buildPrayerInput(prayer)),
                  if (_hasValidInput) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withValues(alpha: 0.2),
                            Colors.teal.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total completed:',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _totalToComplete.toString(),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'May Allah accept your prayers!',
                                style: TextStyle(
                                  color: Colors.green[300],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: _hasValidInput ? _onComplete : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Complete'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerInput(String prayer) {
    final color = _getPrayerColor(prayer);
    final maxCount = widget.currentCounts[prayer] ?? 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getPrayerIcon(prayer),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayer,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Available: $maxCount',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _decrementCount(prayer),
                icon: const Icon(Icons.remove, color: Colors.grey),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              Container(
                width: 60,
                child: TextField(
                  controller: _controllers[prayer],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: color),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                  onChanged: (value) => _updateCount(prayer, value),
                ),
              ),
              IconButton(
                onPressed: () => _incrementCount(prayer),
                icon: const Icon(Icons.add, color: Colors.grey),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _setMaxCount(prayer),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Max',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPrayerColor(String prayer) {
    switch (prayer) {
      case 'Fajr': return Colors.blue;
      case 'Zuhr': return Colors.orange;
      case 'Asr': return Colors.amber;
      case 'Maghrib': return Colors.pink;
      case 'Isha': return Colors.purple;
      case 'Witr': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'Fajr': return Icons.wb_twilight;
      case 'Zuhr': return Icons.wb_sunny;
      case 'Asr': return Icons.wb_sunny_outlined;
      case 'Maghrib': return Icons.nights_stay;
      case 'Isha': return Icons.nightlight;
      case 'Witr': return Icons.star;
      default: return Icons.mosque;
    }
  }
}