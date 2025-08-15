import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/qibla_data.dart';

/// A beautiful animated compass widget that shows Qibla direction
class CompassWidget extends StatefulWidget {
  final QiblaData qiblaData;
  final double size;

  const CompassWidget({
    super.key,
    required this.qiblaData,
    this.size = 280,
  });

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.green.shade800,
            Colors.green.shade600,
            Colors.green.shade400,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass markings
          ..._buildCompassMarkings(),
          
          // Qibla direction indicator
          _buildQiblaIndicator(),
          
          // Center dot
          _buildCenterDot(),
        ],
      ),
    );
  }

  /// Build compass markings (degrees and cardinal directions)
  List<Widget> _buildCompassMarkings() {
    return List.generate(36, (index) {
      final angle = index * 10.0;
      final isMainDirection = index % 9 == 0; // Every 90 degrees
      final isCardinal = index % 18 == 0; // Every 180 degrees (N, S)
      final isIntercardinal = index % 9 == 0 && !isCardinal; // E, W
      
      return Transform.rotate(
        angle: angle * math.pi / 180,
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              // Degree markers
              Container(
                width: isMainDirection ? 3 : 1,
                height: isMainDirection ? 20 : 10,
                color: Colors.white.withOpacity(0.8),
              ),
              
              // Cardinal direction labels
              if (isCardinal || isIntercardinal)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Transform.rotate(
                    angle: -angle * math.pi / 180,
                    child: Text(
                      _getDirectionLabel(angle),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  /// Build the animated Qibla direction indicator
  Widget _buildQiblaIndicator() {
    return Transform.rotate(
      angle: widget.qiblaData.bearing * math.pi / 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing Kaaba marker
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + 0.1 * math.sin(_pulseController.value * 2 * math.pi),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.place,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          
          // Direction line
          Container(
            width: 2,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.amber,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the center dot of the compass
  Widget _buildCenterDot() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.green.shade800, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  /// Get direction label for compass markings
  String _getDirectionLabel(double angle) {
    if (angle == 0) return 'N';
    if (angle == 90) return 'E';
    if (angle == 180) return 'S';
    if (angle == 270) return 'W';
    return '';
  }
}