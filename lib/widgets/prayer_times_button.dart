// widgets/prayer_times_button.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class PrayerTimesButton extends StatefulWidget {
  final AnimationController controller;
  final VoidCallback onPressed;

  const PrayerTimesButton({
    super.key,
    required this.controller,
    required this.onPressed,
  });

  @override
  State<PrayerTimesButton> createState() => _PrayerTimesButtonState();
}

class _PrayerTimesButtonState extends State<PrayerTimesButton>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  void _startAnimations() {
    // Listen to main controller to start pulse animation
    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.forward && mounted) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _pulseController.repeat(reverse: true);
          }
        });
      }
    });

    // Fallback timer
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: widget.controller,
            curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
          ),
        );

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: _buildAnimatedButton(),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _hoverController,
        _pulseController,
        _rippleController,
      ]),
      builder: (context, child) {
        final hoverValue = _hoverController.value;
        final pulseValue = _pulseController.value;
        final rippleValue = _rippleController.value;

        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: GestureDetector(
            onTapDown: (_) => _rippleController.forward(),
            onTapUp: (_) => _rippleController.reverse(),
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()
                ..scale(1.0 + (hoverValue * 0.05) + (pulseValue * 0.02)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF2ECC71,
                      ).withOpacity(0.3 + hoverValue * 0.2),
                      blurRadius: 20 + hoverValue * 10,
                      spreadRadius: 2 + hoverValue * 3,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Main button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.lerp(
                              const Color(0xFF2ECC71),
                              const Color(0xFF27AE60),
                              hoverValue,
                            )!,
                            Color.lerp(
                              const Color(0xFF27AE60),
                              const Color(0xFF2ECC71),
                              hoverValue,
                            )!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated icon
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            transform: Matrix4.identity()
                              ..rotateZ(hoverValue * 0.1),
                            child: Icon(
                              Icons.access_time_rounded,
                              color: Colors.white,
                              size: 24 + hoverValue * 2,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Button text with shimmer
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white,
                                Colors.white.withValues(alpha: 0.8),
                                Colors.white,
                              ],
                              stops: [
                                0.0,
                                math.sin(pulseValue * math.pi) * 0.5 + 0.5,
                                1.0,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'View Prayer Times',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Arrow icon with bounce animation
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            transform: Matrix4.identity()
                              ..translate(hoverValue * 5, 0),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20 + hoverValue * 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ripple effect overlay
                    if (rippleValue > 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white.withValues(
                              alpha: 0.1 * rippleValue,
                            ),
                          ),
                        ),
                      ),

                    // Floating particles
                    ..._buildFloatingParticles(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  List<Widget> _buildFloatingParticles() {
    if (!_isHovered) return [];

    return List.generate(4, (index) {
      final double angle =
          (index * math.pi / 2) + (_pulseController.value * math.pi * 2);
      final double radius =
          40 + math.sin(_pulseController.value * math.pi * 2) * 5;
      final double x = math.cos(angle) * radius;
      final double y = math.sin(angle) * radius;

      return Positioned(
        left: x + 80,
        top: y + 25,
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.6),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: .8),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      );
    });
  }
}
