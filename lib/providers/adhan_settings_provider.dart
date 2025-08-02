// lib/providers/adhan_settings_provider.dart

// lib/providers/adhan_settings_provider.dart

import 'package:flutter/material.dart';
import '../services/adhan_service.dart';

class AdhanSettingsProvider extends ChangeNotifier {
  double _volume = 0.8;
  String _adhanType = 'makkah';
  Map<String, bool> _notificationSettings = {};

  double get volume => _volume;
  String get adhanType => _adhanType;
  Map<String, bool> get notificationSettings => _notificationSettings;

  Future<void> loadSettings() async {
    _volume = await AdhanService.getAdhanVolume();
    _adhanType = await AdhanService.getSelectedAdhanType();
    _notificationSettings = await AdhanService.getNotificationSettings();
    notifyListeners();
  }

  Future<void> setVolume(double v) async {
    _volume = v;
    await AdhanService.setAdhanVolume(v);
    notifyListeners();
  }

  Future<void> setAdhanType(String type) async {
    _adhanType = type;
    await AdhanService.setSelectedAdhanType(type);
    notifyListeners();
  }

  Future<void> toggleNotification(String prayer, bool enabled) async {
    _notificationSettings[prayer] = enabled;
    await AdhanService.updateNotificationSetting(prayer, enabled);
    notifyListeners();
  }
}
