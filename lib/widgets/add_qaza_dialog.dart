// widgets/add_qaza_dialog.dart
// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/qaza_service.dart';

class AddQazaDialog extends StatefulWidget {
  final Function(Map<String, int>) onAdd;

  const AddQazaDialog({super.key, required this.onAdd});

  @override
  State<AddQazaDialog> createState() => _AddQazaDialogState();
}

class _AddQazaDialogState extends State<AddQazaDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    for (String prayer in QazaService.prayerTypes) {
      _controllers[prayer] = TextEditingController();
      _counts[prayer] = 0;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateCount(String prayer, String value) {
    setState(() {
      _counts[prayer] = int.tryParse(value) ?? 0;
    });
  }

  void _incrementCount(String prayer) {
    setState(() {
      _counts[prayer] = (_counts[prayer] ?? 0) + 1;
      _controllers[prayer]!.text = _counts[prayer].toString();
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

  bool get _hasValidInput {
    return _counts.values.any((count) => count > 0);
  }

  int get _totalToAdd {
    return _counts.values.fold(0, (sum, count) => sum + count);
  }

  void _onAdd() {
    if (_hasValidInput) {
      final nonZeroCounts = <String, int>{};
      _counts.forEach((prayer, count) {
        if (count > 0) {
          nonZeroCounts[prayer] = count;
        }
      });
      widget.onAdd(nonZeroCounts);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Add Qaza Prayers',
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
              'Enter the number of missed prayers for each type',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ...QazaService.prayerTypes.map((prayer) => _buildPrayerInput(prayer)),
            if (_hasValidInput) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total to add:',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _totalToAdd.toString(),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
          onPressed: _hasValidInput ? _onAdd : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildPrayerInput(String prayer) {
    final color = _getPrayerColor(prayer);
    
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
            child: Text(
              prayer,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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