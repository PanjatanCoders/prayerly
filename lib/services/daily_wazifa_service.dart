import '../models/dhikr_models.dart';
import 'dhikr_data_service.dart';

/// Looks up the day-specific wazifa (see `DhikrDataService._getDailyWazifaDhikr`
/// for the actual text/sourcing) by weekday, for the morning reminder and
/// its tap-to-recite dialog. The Dhikr entries themselves are the single
/// source of truth - this is just the weekday -> id mapping.
class DailyWazifaService {
  DailyWazifaService._();

  static const Map<int, String> _idByWeekday = {
    DateTime.monday: 'wazifa_monday',
    DateTime.tuesday: 'wazifa_tuesday',
    DateTime.wednesday: 'wazifa_wednesday',
    DateTime.thursday: 'wazifa_thursday',
    DateTime.friday: 'wazifa_friday',
    DateTime.saturday: 'wazifa_saturday',
    DateTime.sunday: 'wazifa_sunday',
  };

  static Dhikr forWeekday(int weekday) {
    final id = _idByWeekday[weekday]!;
    return DhikrDataService.getAllDhikr().firstWhere((d) => d.id == id);
  }

  static Dhikr forDate(DateTime date) => forWeekday(date.weekday);

  static Dhikr today() => forWeekday(DateTime.now().weekday);
}
