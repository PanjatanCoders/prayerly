// welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prayerly/screens/prayer_times_screen.dart';
import 'package:prayerly/widgets/animated_background.dart';
import 'package:prayerly/widgets/animated_mosque_icon.dart';
import 'package:prayerly/widgets/animated_title.dart';
import 'package:prayerly/widgets/footer_info.dart';
import 'package:prayerly/widgets/prayer_times_button.dart';
import 'package:prayerly/widgets/quran_verse_card.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  String _version = '';
  late AnimationController _masterController;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _fetchVersion();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _masterController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
  }

  void _startAnimations() {
    // Start animations after the first frame to ensure proper initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _masterController.forward();
        _backgroundController.repeat();
      }
    });
  }

  Future<void> _fetchVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = info.version;
        });
      }
    } catch (e) {
      // Fallback version if package info fails
      print('Error fetching version: $e');
      if (mounted) {
        setState(() {
          _version = '1.0.0';
        });
      }
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A), // Deep black
              Color(0xFF1A1A1A), // Dark gray
              Color(0xFF0D2818), // Dark Islamic green
              Color(0xFF0A0A0A), // Back to black
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background
              AnimatedBackground(controller: _backgroundController),

              // Main content - Now scrollable to prevent overflow
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Top flexible space
                            SizedBox(height: constraints.maxHeight * 0.02),

                            // Animated mosque icon
                            AnimatedMosqueIcon(controller: _masterController),

                            const SizedBox(height: 20),

                            // Animated title
                            AnimatedTitle(controller: _masterController),

                            const SizedBox(height: 32),

                            // Quran verse card
                            QuranVerseCard(controller: _masterController),

                            const SizedBox(height: 20),

                            // Prayer times button
                            PrayerTimesButton(
                              controller: _masterController,
                              onPressed: () => _navigateToPrayerTimes(context),
                            ),

                            // Dynamic spacing instead of Spacer
                            // SizedBox(height: constraints.maxHeight * 0.1),
                            SizedBox(height: 20),

                            // Footer info
                            FooterInfo(
                              controller: _masterController,
                              version: _version,
                            ),

                            // Bottom padding
                            SizedBox(height: constraints.maxHeight * 0.02),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPrayerTimes(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PrayerTimesScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}
