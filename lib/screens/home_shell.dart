import 'package:flutter/material.dart';
import 'package:prayerly/screens/compass/qibla_compass_screen.dart';
import 'package:prayerly/screens/dhikr/dhikr_selection_screen.dart';
import 'package:prayerly/screens/prayer_times_screen.dart';
import 'package:prayerly/screens/qaza/qaza_tracker_screen.dart';
import 'package:prayerly/screens/zakat/zakat_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  late final List<Widget> _pages = const [
    PrayerTimesScreen(),
    QiblaCompassScreen(),
    DhikrSelectionScreen(),
    QazaTrackerScreen(),
    ZakatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _index,
        onDestinationSelected: (value) {
          if (value == _index) return;
          setState(() {
            _index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.access_time),
            selectedIcon: Icon(Icons.access_time_filled),
            label: 'Prayer',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Qibla',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            selectedIcon: Icon(Icons.circle),
            label: 'Dhikr',
          ),
          NavigationDestination(
            icon: Icon(Icons.format_list_numbered),
            selectedIcon: Icon(Icons.format_list_numbered_rtl),
            label: 'Qaza',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism),
            label: 'Zakat',
          ),
        ],
      ),
    );
  }
}
