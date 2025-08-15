// widgets/dhikr_counter_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:prayerly/services/dhikr_service.dart';

/// Main counter widget with circular progress and tap area
class DhikrCounterWidget extends StatefulWidget {
  final int count;
  final int targetCount;
  final VoidCallback onTap;
  final VoidCallback onReset;
  final VoidCallback onTargetEdit;
  final Color primaryColor;
  final bool showProgress;

  const DhikrCounterWidget({
    super.key,
    required this.count,
    required this.targetCount,
    required this.onTap,
    required this.onReset,
    required this.onTargetEdit,
    this.primaryColor = Colors.green,
    this.showProgress = true,
  });

  @override
  State<DhikrCounterWidget> createState() => _DhikrCounterWidgetState();
}

class _DhikrCounterWidgetState extends State<DhikrCounterWidget>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    _updateProgress();
  }

  @override
  void didUpdateWidget(DhikrCounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count || oldWidget.targetCount != widget.targetCount) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final progress = DhikrService.calculateProgress(widget.count, widget.targetCount);
    _progressController.animateTo(progress);
  }

  @override
  void dispose() {
    _tapController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) {
      _tapController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final progress = DhikrService.calculateProgress(widget.count, widget.targetCount);
    final isComplete = DhikrService.isTargetReached(widget.count, widget.targetCount);
    
    return Column(
      children: [
        // Main counter circle
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: _handleTap,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.primaryColor.withValues(alpha: 0.1),
                        widget.primaryColor.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress circle
                      if (widget.showProgress)
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(260, 260),
                              painter: CircularProgressPainter(
                                progress: _progressAnimation.value,
                                color: widget.primaryColor,
                                strokeWidth: 8,
                              ),
                            );
                          },
                        ),
                      
                      // Counter display
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Current count
                          Text(
                            DhikrService.formatCount(widget.count),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: widget.primaryColor,
                            ),
                          ),
                          
                          // Target indicator
                          Text(
                            'of ${DhikrService.formatCount(widget.targetCount)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Progress percentage
                          if (widget.showProgress)
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: widget.primaryColor,
                              ),
                            ),
                          
                          // Completion indicator
                          if (isComplete)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'COMPLETED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      // Tap area indicator
                      Positioned(
                        bottom: 40,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tap to count',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 20),
        
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Reset button
            _buildActionButton(
              icon: Icons.refresh,
              label: 'Reset',
              onPressed: widget.onReset,
              color: Colors.orange,
            ),
            
            // Edit target button
            _buildActionButton(
              icon: Icons.edit,
              label: 'Target',
              onPressed: widget.onTargetEdit,
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}

/// Custom painter for circular progress indicator
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}