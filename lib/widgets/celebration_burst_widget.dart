import 'package:flutter/material.dart';

/// A brief, self-dismissing burst of expanding rings behind a bouncing icon,
/// inserted into the nearest [Overlay]. Fire-and-forget: call [show] and
/// move on, the entry removes itself once the animation finishes.
class CelebrationBurst {
  CelebrationBurst._();

  static void show(
    BuildContext context, {
    IconData icon = Icons.celebration,
    Color color = Colors.amber,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _CelebrationBurstOverlay(
        icon: icon,
        color: color,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _CelebrationBurstOverlay extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onDone;

  const _CelebrationBurstOverlay({
    required this.icon,
    required this.color,
    required this.onDone,
  });

  @override
  State<_CelebrationBurstOverlay> createState() =>
      _CelebrationBurstOverlayState();
}

class _CelebrationBurstOverlayState extends State<_CelebrationBurstOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            // Icon bounces in over the first third, holds, then fades out.
            final iconScale = t < 0.35
                ? Curves.elasticOut.transform(t / 0.35)
                : 1.0;
            final fadeOut = t > 0.7 ? 1.0 - ((t - 0.7) / 0.3) : 1.0;

            return SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (final delay in [0.0, 0.15, 0.3])
                    _ExpandingRing(
                      progress: ((t - delay).clamp(0.0, 1.0)),
                      color: widget.color,
                    ),
                  Opacity(
                    opacity: fadeOut.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: iconScale,
                      child: Icon(widget.icon, color: widget.color, size: 64),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExpandingRing extends StatelessWidget {
  final double progress;
  final Color color;

  const _ExpandingRing({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final size = 40 + (progress * 160);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: opacity * 0.6),
          width: 2,
        ),
      ),
    );
  }
}
