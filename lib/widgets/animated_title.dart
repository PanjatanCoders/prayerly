import 'package:flutter/material.dart';

class AnimatedTitle extends StatelessWidget {
  final AnimationController controller;
  final String? subtitle; // Add optional subtitle parameter

  const AnimatedTitle({
    super.key, 
    required this.controller,
    this.subtitle, // Optional subtitle
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Column(
              children: [
                // App name with shimmer effect
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF2ECC71),
                      Color(0xFF27AE60),
                      Color(0xFFFFFFFF),
                      Color(0xFF2ECC71),
                    ],
                    stops: [0.0, 0.3, 0.6, 1.0],
                  ).createShader(bounds),
                  child: const Text(
                    'Prayerly',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Color(0xFF2ECC71),
                          blurRadius: 20,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle - now uses parameter or fallback
                Text(
                  subtitle ?? 'Your Spiritual Companion',
                  style: TextStyle(
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center, // Center align for all languages
                ),

                const SizedBox(height: 16),

                // Decorative line with animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  width: fadeAnimation.value * 80,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFF2ECC71),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}