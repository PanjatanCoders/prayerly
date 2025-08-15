// screens/dhikr_counter_screen.dart
import 'package:flutter/material.dart';
import 'package:prayerly/models/dhikr_models.dart';
import 'package:prayerly/services/dhikr_service.dart';
import 'package:prayerly/widgets/dhikar/dhikr_counter_widget.dart';
import 'package:prayerly/widgets/dhikar/dhikr_text_widget.dart';
/// Main Dhikr counter screen
class DhikrCounterScreen extends StatefulWidget {
  final Dhikr dhikr;
  final DhikrSettings? settings;

  const DhikrCounterScreen({
    super.key,
    required this.dhikr,
    this.settings,
  });

  @override
  State<DhikrCounterScreen> createState() => _DhikrCounterScreenState();
}

class _DhikrCounterScreenState extends State<DhikrCounterScreen> {
  late int _count;
  late int _targetCount;
  late DhikrSettings _settings;
  late DateTime _sessionStartTime;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _count = 0;
    _targetCount = widget.dhikr.targetCount;
    _settings = widget.settings ?? const DhikrSettings();
    _sessionStartTime = DateTime.now();
  }

  void _incrementCount() async {
    if (_count < _targetCount) {
      setState(() {
        _count++;
      });

      // Check if completed
      if (_count >= _targetCount && !_isCompleted) {
        _isCompleted = true;
        await _handleCompletion();
      } else {
        await DhikrService.provideFeedback(
          enableHaptic: _settings.enableHapticFeedback,
          enableSound: _settings.enableSound,
        );
      }
    } else if (_settings.autoReset) {
      _resetCount();
    }
  }

  Future<void> _handleCompletion() async {
    await DhikrService.provideFeedback(
      enableHaptic: _settings.enableHapticFeedback,
      enableSound: _settings.enableSound,
      isComplete: true,
    );

    if (mounted) {
      _showCompletionDialog();
    }
  }

  void _resetCount() {
    setState(() {
      _count = 0;
      _isCompleted = false;
      _sessionStartTime = DateTime.now();
    });
  }

  void _editTarget() {
    showDialog(
      context: context,
      builder: (context) => _EditTargetDialog(
        currentTarget: _targetCount,
        onTargetChanged: (newTarget) {
          setState(() {
            _targetCount = newTarget;
            _isCompleted = false;
          });
        },
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SettingsBottomSheet(
        settings: _settings,
        onSettingsChanged: (newSettings) {
          setState(() {
            _settings = newSettings;
          });
        },
      ),
    );
  }

  void _showCompletionDialog() {
    final sessionDuration = DateTime.now().difference(_sessionStartTime);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.celebration,
              color: widget.dhikr.category.color,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('Dhikr Completed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DhikrService.getCompletionMessage(widget.dhikr),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.dhikr.category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Count:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('$_count'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Duration:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(DhikrService.formatDuration(sessionDuration)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetCount();
            },
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.dhikr.category.color,
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.dhikr.transliteration),
        backgroundColor: widget.dhikr.category.color,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Dhikr text display
            DhikrDisplayWidget(
              dhikr: widget.dhikr,
              settings: _settings,
            ),
            
            const SizedBox(height: 30),
            
            // Counter widget
            DhikrCounterWidget(
              count: _count,
              targetCount: _targetCount,
              onTap: _incrementCount,
              onReset: _resetCount,
              onTargetEdit: _editTarget,
              primaryColor: widget.dhikr.category.color,
            ),
            
            const SizedBox(height: 20),
            
            // Progress info
            _buildProgressInfo(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressInfo() {
    final progress = DhikrService.calculateProgress(_count, _targetCount);
    final remaining = DhikrService.getRemainingCount(_count, _targetCount);
    final sessionDuration = DateTime.now().difference(_sessionStartTime);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                label: 'Remaining',
                value: '$remaining',
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
              _buildInfoItem(
                label: 'Progress',
                value: '${(progress * 100).toStringAsFixed(0)}%',
                icon: Icons.percent,
                color: Colors.blue,
              ),
              _buildInfoItem(
                label: 'Duration',
                value: DhikrService.formatDuration(sessionDuration),
                icon: Icons.timer,
                color: Colors.green,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Encouragement message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.dhikr.category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: widget.dhikr.category.color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DhikrService.getEncouragementMessage(progress),
                    style: TextStyle(
                      color: widget.dhikr.category.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// Dialog for editing target count
class _EditTargetDialog extends StatefulWidget {
  final int currentTarget;
  final Function(int) onTargetChanged;

  const _EditTargetDialog({
    required this.currentTarget,
    required this.onTargetChanged,
  });

  @override
  State<_EditTargetDialog> createState() => _EditTargetDialogState();
}

class _EditTargetDialogState extends State<_EditTargetDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTarget.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveTarget() {
    final error = DhikrService.validateTargetCount(_controller.text);
    if (error != null) {
      setState(() {
        _errorText = error;
      });
      return;
    }

    final newTarget = int.parse(_controller.text);
    widget.onTargetChanged(newTarget);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Target Count'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Target Count',
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _errorText = null;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Common targets: 33, 99, 100',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTarget,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Bottom sheet for settings
class _SettingsBottomSheet extends StatefulWidget {
  final DhikrSettings settings;
  final Function(DhikrSettings) onSettingsChanged;

  const _SettingsBottomSheet({
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<_SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<_SettingsBottomSheet> {
  late DhikrSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _updateSettings(DhikrSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Dhikr Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Settings options
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibrate on each count'),
            value: _settings.enableHapticFeedback,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(enableHapticFeedback: value));
            },
          ),
          
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Play sound on count'),
            value: _settings.enableSound,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(enableSound: value));
            },
          ),
          
          SwitchListTile(
            title: const Text('Show Arabic Text'),
            subtitle: const Text('Display Arabic dhikr text'),
            value: _settings.showArabicText,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(showArabicText: value));
            },
          ),
          
          SwitchListTile(
            title: const Text('Show Transliteration'),
            subtitle: const Text('Display phonetic pronunciation'),
            value: _settings.showTransliteration,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(showTransliteration: value));
            },
          ),
          
          SwitchListTile(
            title: const Text('Show Translation'),
            subtitle: const Text('Display English meaning'),
            value: _settings.showTranslation,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(showTranslation: value));
            },
          ),
          
          SwitchListTile(
            title: const Text('Auto Reset'),
            subtitle: const Text('Reset counter when target reached'),
            value: _settings.autoReset,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(autoReset: value));
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}