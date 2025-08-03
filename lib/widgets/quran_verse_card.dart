// widgets/quran_verse_card.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class QuranVerseCard extends StatefulWidget {
  final AnimationController controller;

  const QuranVerseCard({super.key, required this.controller});

  @override
  State<QuranVerseCard> createState() => _QuranVerseCardState();
}

class _QuranVerseCardState extends State<QuranVerseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Start shimmer after the main animation begins
    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.forward && mounted) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _shimmerController.repeat();
          }
        });
      }
    });

    // Fallback timer
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_shimmerController.isAnimating) {
        _shimmerController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.4, 0.8, curve: Curves.elasticOut),
      ),
    );

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A1A1A).withOpacity(0.8),
                    const Color(0xFF2C2C2C).withOpacity(0.6),
                    const Color(0xFF1A1A1A).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF2ECC71).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Islamic decoration at top
                  _buildIslamicDecoration(),

                  const SizedBox(height: 20),

                  // Quran verse with shimmer effect
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: const [
                              Colors.white70,
                              Colors.white,
                              Colors.white70,
                            ],
                            stops: [
                              0.0,
                              math.sin(_shimmerController.value * math.pi) *
                                      0.5 +
                                  0.5,
                              1.0,
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          '"Indeed, prayer prohibits immorality and wrongdoing, and the remembrance of Allah is greater."',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            height: 1.7,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Verse reference with glow effect
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2ECC71).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Qur\'an 29:45',
                      style: TextStyle(
                        color: const Color(0xFF2ECC71).withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom decoration
                  _buildBottomDecoration(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIslamicDecoration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDecorationDot(),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFF2ECC71).withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildDecorationStar(),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFF2ECC71).withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildDecorationDot(),
      ],
    );
  }

  Widget _buildBottomDecoration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2ECC71).withOpacity(0.4),
          ),
        );
      }),
    );
  }

  Widget _buildDecorationDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2ECC71).withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildDecorationStar() {
    return SizedBox(
      width: 12,
      height: 12,
      child: CustomPaint(
        painter: StarPainter(color: const Color(0xFF2ECC71).withOpacity(0.8)),
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  final Color color;

  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final outerRadius = i % 2 == 0 ? radius : radius * 0.5;
      final x = centerX + math.cos(angle) * outerRadius;
      final y = centerY + math.sin(angle) * outerRadius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
