import 'package:flutter/material.dart';
import 'package:prayerly/screens/home_shell.dart';
import 'package:prayerly/utils/theme/app_theme.dart';
import 'package:prayerly/utils/theme/app_transitions.dart';

/// Branded launch splash. Shows the bold "PRAYERLY" wordmark for a beat while
/// services finish warming up in main(), then hands off to HomeShell.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _wordmarkFade;
  late final Animation<Offset> _wordmarkSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _wordmarkFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _wordmarkSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controller.forward();
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) _goHome();
    });
  }

  void _goHome() {
    Navigator.of(
      context,
    ).pushReplacement(AppTransitions.fadeThrough(const HomeShell()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onPrimary = AppTheme.white;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0A0A0A),
                    Color(0xFF0D2818),
                    Color(0xFF0A0A0A),
                  ]
                : const [AppTheme.primaryGreen, Color(0xFF1B5E20)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return SlideTransition(
                position: _wordmarkSlide,
                child: FadeTransition(
                  opacity: _wordmarkFade,
                  child: Text(
                    'PRAYERLY',
                    style: TextStyle(
                      color: onPrimary,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
