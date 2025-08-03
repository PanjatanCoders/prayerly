import 'package:flutter/material.dart';
import '../services/adhan_service.dart';

class AdhanSettingsProvider extends ChangeNotifier {
  double _volume = 0.8;
  String _adhanType = 'azan1';
  bool _autoPlayEnabled = true;
  Map<String, bool> _notificationSettings = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  // Getters
  double get volume => _volume;
  String get adhanType => _adhanType;
  bool get autoPlayEnabled => _autoPlayEnabled;
  Map<String, bool> get notificationSettings => _notificationSettings;

  AdhanSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _volume = await AdhanService.getAdhanVolume();
      _adhanType = await AdhanService.getSelectedAdhanType();
      _autoPlayEnabled = await AdhanService.getAutoPlayEnabled();
      _notificationSettings = await AdhanService.getNotificationSettings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading adhan settings: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    notifyListeners();
    try {
      await AdhanService.setAdhanVolume(volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  Future<void> setAdhanType(String type) async {
    _adhanType = type;
    notifyListeners();
    try {
      await AdhanService.setSelectedAdhanType(type);
    } catch (e) {
      debugPrint('Error setting adhan type: $e');
    }
  }

  Future<void> setAutoPlayEnabled(bool enabled) async {
    _autoPlayEnabled = enabled;
    notifyListeners();
    try {
      await AdhanService.setAutoPlayEnabled(enabled);
    } catch (e) {
      debugPrint('Error setting auto play: $e');
    }
  }

  Future<void> toggleNotification(String prayer, bool enabled) async {
    _notificationSettings[prayer] = enabled;
    notifyListeners();
    try {
      await AdhanService.updateNotificationSetting(prayer, enabled);
    } catch (e) {
      debugPrint('Error updating notification setting: $e');
    }
  }

  Future<void> refreshSettings() async {
    await _loadSettings();
  }
}