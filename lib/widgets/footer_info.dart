// widgets/footer_info.dart
import 'package:flutter/material.dart';

class FooterInfo extends StatefulWidget {
  final AnimationController controller;
  final String version;

  const FooterInfo({
    super.key,
    required this.controller,
    required this.version,
  });

  @override
  State<FooterInfo> createState() => _FooterInfoState();
}

class _FooterInfoState extends State<FooterInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Start glow animation after the main animation completes
    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _glowController.repeat(reverse: true);
      }
    });

    // Fallback timer in case the listener doesn't trigger
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted && !_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: widget.controller,
            curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
          ),
        );

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: _buildFooterContent(),
          ),
        );
      },
    );
  }

  Widget _buildFooterContent() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowValue = _glowController.value;

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                const Color(0xFF1A1A1A).withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF2ECC71).withValues(alpha: 0.1 + glowValue * 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Company name with glow effect
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    const Color(0xFF2ECC71).withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.9),
                    const Color(0xFF2ECC71).withValues(alpha: 0.8),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: Text(
                  "2025 Raza Technology Solutions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: const Color(
                          0xFF2ECC71,
                        ).withValues(alpha: glowValue * 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Rights reserved text
              Text(
                "All rights reserved",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 6),

              // Decorative separator
              Container(
                width: 60,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(
                        0xFF2ECC71,
                      ).withValues(alpha: 0.5 + glowValue * 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Version info with animated container
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF2ECC71,
                  ).withValues(alpha: 0.1 + glowValue * 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(
                      0xFF2ECC71,
                    ).withValues(alpha: 0.2 + glowValue * 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: const Color(0xFF2ECC71).withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Version ${widget.version.isEmpty ? '...' : widget.version}",
                      style: TextStyle(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bottom decorative dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 500 + index * 100),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 4 + (glowValue * 2),
                    height: 4 + (glowValue * 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(
                        0xFF2ECC71,
                      ).withValues(alpha: 0.4 + glowValue * 0.3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF2ECC71,
                          ).withValues(alpha: glowValue * 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
