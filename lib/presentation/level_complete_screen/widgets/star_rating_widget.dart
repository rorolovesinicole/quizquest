import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Star rating display widget with animated reveal sequence
///
/// Features:
/// - Animated star reveal with scale and fade effects
/// - Audio fanfare integration (handled by parent)
/// - Long-press for detailed scoring breakdown
/// - Accessibility support with semantic labels
class StarRatingWidget extends StatefulWidget {
  final int stars;
  final VoidCallback onLongPress;

  const StarRatingWidget({
    super.key,
    required this.stars,
    required this.onLongPress,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _starAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create staggered animations for each star
    _starAnimations = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.4;
      return CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.elasticOut),
      );
    });

    // Start animation after brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Semantics(
        label:
            '${widget.stars} out of 3 stars earned. Long press for detailed breakdown.',
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isEarned = index < widget.stars;
              return AnimatedBuilder(
                animation: _starAnimations[index],
                builder: (context, child) {
                  final scale = _starAnimations[index].value;
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: scale,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.w),
                        child: CustomIconWidget(
                          iconName: isEarned ? 'star' : 'star_border',
                          color: isEarned
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                          size: 15.w,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}
