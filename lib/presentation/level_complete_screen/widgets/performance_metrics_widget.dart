import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Performance metrics display with animated reveals
///
/// Shows:
/// - Accuracy percentage
/// - Time taken
/// - Knowledge gems collected
/// - Bonus points earned
class PerformanceMetricsWidget extends StatefulWidget {
  final double accuracy;
  final Duration timeTaken;
  final int gemsCollected;
  final int bonusPoints;

  const PerformanceMetricsWidget({
    super.key,
    required this.accuracy,
    required this.timeTaken,
    required this.gemsCollected,
    required this.bonusPoints,
  });

  @override
  State<PerformanceMetricsWidget> createState() =>
      _PerformanceMetricsWidgetState();
}

class _PerformanceMetricsWidgetState extends State<PerformanceMetricsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(milliseconds: 600), () {
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
    final minutes = widget.timeTaken.inMinutes;
    final seconds = widget.timeTaken.inSeconds % 60;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildMetricRow(
              context,
              icon: 'check_circle',
              label: 'Accuracy',
              value: '${widget.accuracy.toStringAsFixed(1)}%',
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            _buildMetricRow(
              context,
              icon: 'timer',
              label: 'Time Taken',
              value: '${minutes}m ${seconds}s',
              color: theme.colorScheme.secondary,
            ),
            SizedBox(height: 2.h),
            _buildMetricRow(
              context,
              icon: 'diamond',
              label: 'Knowledge Gems',
              value: '${widget.gemsCollected}',
              color: theme.colorScheme.tertiary,
            ),
            if (widget.bonusPoints > 0) ...[
              SizedBox(height: 2.h),
              _buildMetricRow(
                context,
                icon: 'stars',
                label: 'Bonus Points',
                value: '+${widget.bonusPoints}',
                color: AppTheme.getSuccessColor(
                  theme.brightness == Brightness.light,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(iconName: icon, color: color, size: 6.w),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
