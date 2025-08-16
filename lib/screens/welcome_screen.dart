// welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prayerly/screens/prayer_times_screen.dart';
import 'package:prayerly/widgets/animated_background.dart';
// import 'package:prayerly/widgets/animated_mosque_icon.dart';
import 'package:prayerly/widgets/animated_title.dart';
import 'package:prayerly/widgets/footer_info.dart';
import 'package:prayerly/widgets/prayer_times_button.dart';
import 'package:prayerly/widgets/quran_verse_card.dart';
import 'package:prayerly/services/language_service.dart';

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
  late AnimationController _languageController;

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

    _languageController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _startAnimations() {
    // Start animations after the first frame to ensure proper initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _masterController.forward();
        _backgroundController.repeat();
        // Start language animation after a slight delay
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _languageController.forward();
          }
        });
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
      debugPrint('Error fetching version: $e');
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
    _languageController.dispose();
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

              // Language selector button in top-right corner
              _buildLanguageButton(),

              // Main content - Now scrollable to prevent overflow
              LayoutBuilder(
                builder: (context, constraints) {
                  return ValueListenableBuilder<Locale>(
                    valueListenable: LanguageService.localeNotifier,
                    builder: (context, locale, child) {
                      return Directionality(
                        textDirection: LanguageService.textDirection,
                        child: SingleChildScrollView(
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
                                  // AnimatedMosqueIcon(controller: _masterController),

                                  // const SizedBox(height: 20),

                                  // Animated title with localized subtitle
                                  AnimatedTitle(
                                    controller: _masterController,
                                    subtitle: _getSubtitleText(locale.languageCode),
                                  ),

                                  const SizedBox(height: 32),

                                  // Language selection card (prominent)
                                  _buildLanguageSelectionCard(),

                                  const SizedBox(height: 24),

                                  // Quran verse card
                                  QuranVerseCard(controller: _masterController),

                                  const SizedBox(height: 20),

                                  // Prayer times button (keeping original)
                                  PrayerTimesButton(
                                    controller: _masterController,
                                    onPressed: () => _navigateToPrayerTimes(context),
                                  ),

                                  const SizedBox(height: 20),

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
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _languageController,
        builder: (context, child) {
          return Transform.scale(
            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _languageController,
                curve: Curves.elasticOut,
              ),
            ).value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: _showLanguageSelection,
                tooltip: 'Change Language',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageSelectionCard() {
    return AnimatedBuilder(
      animation: _languageController,
      builder: (context, child) {
        return Transform.translate(
          offset: Tween<Offset>(
            begin: const Offset(0, 50),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _languageController,
              curve: Curves.easeOutCubic,
            ),
          ).value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _languageController,
                curve: Curves.easeOut,
              ),
            ).value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.language,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Choose Your Language',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLanguageOptions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOptions() {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.localeNotifier,
      builder: (context, currentLocale, child) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3,
          children: LanguageService.supportedLanguages.entries.map((entry) {
            final languageName = entry.key;
            final locale = entry.value;
            final isSelected = currentLocale.languageCode == locale.languageCode;
            
            return _buildLanguageOption(
              languageName: languageName,
              locale: locale,
              isSelected: isSelected,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required String languageName,
    required Locale locale,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () async {
        await LanguageService.changeLanguage(locale);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Islamic icon instead of emoji
              _buildLanguageIcon(locale.languageCode),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  languageName,
                  style: TextStyle(
                    color: isSelected 
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Localized text methods
  String _getSubtitleText(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return 'आपका आध्यात्मिक साथी';
      case 'ur':
        return 'آپ کا روحانی ساتھی';
      case 'bn':
        return 'আপনার আধ্যাত্মিক সঙ্গী';
      default:
        return 'Your Spiritual Companion';
    }
  }

  void _showLanguageSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0A0A0A),
            ],
          ),
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
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Select Language',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Language options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLanguageOptions(),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageIcon(String languageCode) {
    IconData iconData;
    Color iconColor;
    
    switch (languageCode) {
      case 'en':
        iconData = Icons.mosque; // Mosque for English
        iconColor = const Color(0xFF2ECC71); // Islamic green
        break;
      case 'hi':
        iconData = Icons.star; // Star for Hindi
        iconColor = const Color(0xFFFFD700); // Gold
        break;
      case 'ur':
        iconData = Icons.nightlight; // Crescent moon for Urdu
        iconColor = const Color(0xFF3498DB); // Blue
        break;
      case 'bn':
        iconData = Icons.auto_awesome; // Sparkle/star for Bengali
        iconColor = const Color(0xFF9B59B6); // Purple
        break;
      default:
        iconData = Icons.mosque;
        iconColor = const Color(0xFF2ECC71);
    }
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        iconData,
        size: 14,
        color: iconColor,
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