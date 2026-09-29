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

  // Rebuilt each frame rather than cached, so the compass tab is told when it
  // stops being the visible one and can release the magnetometer.
  List<Widget> get _pages => [
        const PrayerTimesScreen(),
        QiblaCompassScreen(isActive: _index == 1),
        const DhikrSelectionScreen(),
        const QazaTrackerScreen(),
        const ZakatScreen(),
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
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque),
            label: 'Prayer',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Qibla',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Dhikr',
          ),
          NavigationDestination(
            icon: Icon(Icons.format_list_bulleted),
            selectedIcon: Icon(Icons.format_list_bulleted),
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
