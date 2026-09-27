import 'package:flutter/material.dart';

import '../../services/islamic_occasion_service.dart';
import '../../utils/theme/app_theme.dart';

/// Surfaces the current Islamic occasion - Ramadan, the White Days, Jumu'ah,
/// or an upcoming Ramadan countdown - and collapses to nothing on an
/// ordinary day rather than showing a banner with nothing to say.
class OccasionBannerWidget extends StatefulWidget {
  const OccasionBannerWidget({super.key});

  @override
  State<OccasionBannerWidget> createState() => _OccasionBannerWidgetState();
}

class _OccasionBannerWidgetState extends State<OccasionBannerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _entrance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
    _entrance = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final occasion = IslamicOccasionService.currentOccasion(DateTime.now());
    if (occasion == null) return const SizedBox.shrink();

    final accent = AppTheme.legibleAccent(context, AppTheme.primaryAmber);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AnimatedBuilder(
      animation: _entrance,
      builder: (context, child) {
        return Opacity(
          opacity: _entrance.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.94 + (_entrance.value.clamp(0.0, 1.0) * 0.06),
            alignment: Alignment.centerLeft,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [accent.withValues(alpha: 0.16), accent.withValues(alpha: 0.05)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(occasion.icon, color: accent, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    occasion.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: accent,
                    ),
                  ),
                  Text(
                    occasion.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
