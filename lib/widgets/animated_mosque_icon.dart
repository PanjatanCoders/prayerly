// widgets/animated_mosque_icon.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedMosqueIcon extends StatefulWidget {
  final AnimationController controller;

  const AnimatedMosqueIcon({
    super.key,
    required this.controller,
  });

  @override
  State<AnimatedMosqueIcon> createState() => _AnimatedMosqueIconState();
}

class _AnimatedMosqueIconState extends State<AnimatedMosqueIcon>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Scale animation for entrance
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    ));

    // Continuous pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    // Listen to the main controller to start secondary animations
    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.forward && mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _pulseController.repeat(reverse: true);
            _glowController.repeat(reverse: true);
          }
        });
      }
    });

    // Fallback timer
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
        _glowController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _pulseAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF2ECC71).withValues(alpha: 0.2 * _glowAnimation.value),
                  const Color(0xFF27AE60).withValues(alpha: 0.1 * _glowAnimation.value),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2ECC71).withValues(alpha: 0.4 * _glowAnimation.value),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: const Color(0xFF2ECC71).withValues(alpha: 0.2 * _glowAnimation.value),
                  blurRadius: 80,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2ECC71).withValues(alpha: 0.3 * _glowAnimation.value),
                      width: 2,
                    ),
                  ),
                ),
                
                // Inner glow ring
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2ECC71).withValues(alpha: 0.5 * _glowAnimation.value),
                      width: 1,
                    ),
                  ),
                ),
                
                // Main mosque icon
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                    border: Border.all(
                      color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: Color(0xFF2ECC71),
                    size: 50,
                  ),
                ),
                
                // Floating particles around the icon
                ..._buildFloatingParticles(),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(6, (index) {
      final double angle = (index * math.pi / 3) + (_pulseController.value * math.pi * 2);
      final double radius = 60 + math.sin(_glowController.value * math.pi * 2) * 10;
      final double x = math.cos(angle) * radius;
      final double y = math.sin(angle) * radius;
      
      return Positioned(
        left: x + 60,
        top: y + 60,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2ECC71).withValues(alpha: 0.6 * _glowAnimation.value),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2ECC71).withValues(alpha: 0.8),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      );
    });
  }
}