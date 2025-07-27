import 'package:flutter/material.dart';
import 'package:prayerly/screens/prayer_times_screen.dart';

void main() {
  runApp(PrayerTimesApp());
}

class PrayerTimesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: PrayerTimesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}