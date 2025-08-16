// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../services/qaza_service.dart';

class QazaSettingsScreen extends StatefulWidget {
  const QazaSettingsScreen({super.key});

  @override
  State<QazaSettingsScreen> createState() => _QazaSettingsScreenState();
}

class _QazaSettingsScreenState extends State<QazaSettingsScreen> {
  late QazaSettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await QazaService.getQazaSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    await QazaService.saveQazaSettings(_settings);
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _changeDailyTarget(int value) {
    setState(() {
      _settings = _settings.copyWith(dailyTarget: value);
    });
  }

  void _toggleReminders(bool value) {
    setState(() {
      _settings = _settings.copyWith(enableReminders: value);
    });
  }

  void _changeReminderTime(int idx, int newValue) {
    final newTimes = List<int>.from(_settings.reminderTimes);
    newTimes[idx] = newValue;
    setState(() {
      _settings = _settings.copyWith(reminderTimes: newTimes);
    });
  }

  void _addReminderTime() {
    setState(() {
      final newTimes = List<int>.from(_settings.reminderTimes)..add(9);
      _settings = _settings.copyWith(reminderTimes: newTimes);
    });
  }

  void _removeReminderTime(int idx) {
    setState(() {
      final newTimes = List<int>.from(_settings.reminderTimes)..removeAt(idx);
      _settings = _settings.copyWith(reminderTimes: newTimes);
    });
  }

  void _toggleMotivational(bool value) {
    setState(() {
      _settings = _settings.copyWith(showMotivationalMessages: value);
    });
  }

  void _changeCalculationMethod(String value) {
    setState(() {
      _settings = _settings.copyWith(preferredCalculationMethod: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qaza Settings', style: TextStyle(color: Colors.white)),
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
                  // Daily Target
                  Text('Daily Qaza Target', style: _sectionHeaderStyle()),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _settings.dailyTarget.toDouble(),
                          min: 1,
                          max: 20,
                          label: _settings.dailyTarget.toString(),
                          divisions: 19,
                          onChanged: (value) => _changeDailyTarget(value.toInt()),
                          activeColor: Colors.green,
                          inactiveColor: Colors.grey[800],
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '${_settings.dailyTarget}',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Reminders
                  Text('Prayer Reminders', style: _sectionHeaderStyle()),
                  SwitchListTile(
                    value: _settings.enableReminders,
                    onChanged: _toggleReminders,
                    title: const Text('Enable Reminders', style: TextStyle(color: Colors.white)),
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.grey,
                  ),
                  if (_settings.enableReminders) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < _settings.reminderTimes.length; i++)
                          Row(
                            children: [
                              Text(
                                "Time ${i + 1}: ",
                                style: const TextStyle(color: Colors.white),
                              ),
                              DropdownButton<int>(
                                value: _settings.reminderTimes[i],
                                dropdownColor: Colors.grey[900],
                                items: List.generate(
                                  24,
                                  (index) => DropdownMenuItem(
                                    value: index,
                                    child: Text(
                                      TimeOfDay(hour: index, minute: 0).format(context),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null) _changeReminderTime(i, val);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeReminderTime(i),
                              )
                            ],
                          ),
                        TextButton.icon(
                          onPressed: _addReminderTime,
                          icon: const Icon(Icons.add, color: Colors.orange),
                          label: const Text('Add Reminder Time', style: TextStyle(color: Colors.orange)),
                        )
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Motivational Messages
                  Text('Motivational Messages', style: _sectionHeaderStyle()),
                  SwitchListTile(
                    value: _settings.showMotivationalMessages,
                    onChanged: _toggleMotivational,
                    title: const Text('Show Motivational Messages', style: TextStyle(color: Colors.white)),
                    activeColor: Colors.green,
                  ),
                  const SizedBox(height: 24),

                  // Calculation Method
                  Text('Calculation Method', style: _sectionHeaderStyle()),
                  DropdownButton<String>(
                    value: _settings.preferredCalculationMethod,
                    items: const [
                      DropdownMenuItem(value: 'hanafi', child: Text('Hanafi', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 'shafi', child: Text('Shafi', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 'other', child: Text('Other', style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (val) {
                      if (val != null) _changeCalculationMethod(val);
                    },
                    dropdownColor: Colors.grey[900],
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
                      ),
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Save Settings', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  TextStyle _sectionHeaderStyle() => const TextStyle(
        color: Colors.grey,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 3,
      );
}
