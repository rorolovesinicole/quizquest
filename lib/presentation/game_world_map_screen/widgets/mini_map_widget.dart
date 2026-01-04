import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Floating mini-map showing current position and overall progress
///
/// Features:
/// - Simplified zone representation
/// - Current position indicator
/// - Overall progress visualization
class MiniMapWidget extends StatelessWidget {
  final List<Map<String, dynamic>> zones;
  final int currentZoneIndex;
  final VoidCallback onTap;

  const MiniMapWidget({
    super.key,
    required this.zones,
    required this.currentZoneIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25.w,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline, width: 2),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini-map header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Map',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'zoom_in',
                  color: theme.colorScheme.primary,
                  size: 14,
                ),
              ],
            ),

            SizedBox(height: 1.h),

            // Simplified zone representation
            ...List.generate(
              zones.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: _buildMiniZone(
                  theme,
                  zones[index],
                  index == currentZoneIndex,
                ),
              ),
            ),

            SizedBox(height: 0.5.h),

            // Overall progress
            _buildProgressBar(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniZone(
    ThemeData theme,
    Map<String, dynamic> zone,
    bool isCurrent,
  ) {
    final completedLevels = (zone['levels'] as List<Map<String, dynamic>>)
        .where((level) => level['isCompleted'] as bool)
        .length;
    final totalLevels = zone['totalLevels'] as int;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: isCurrent
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isCurrent
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Zone indicator
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: _getZoneColor(zone['theme'] as String),
              shape: BoxShape.circle,
            ),
          ),

          SizedBox(width: 2.w),

          // Progress indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: completedLevels / totalLevels,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getZoneColor(zone['theme'] as String),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    final totalLevels = zones.fold<int>(
      0,
      (sum, zone) => sum + (zone['totalLevels'] as int),
    );
    final completedLevels = zones.fold<int>(
      0,
      (sum, zone) =>
          sum +
          (zone['levels'] as List<Map<String, dynamic>>)
              .where((level) => level['isCompleted'] as bool)
              .length,
    );
    final progress = completedLevels / totalLevels;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getZoneColor(String theme) {
    switch (theme) {
      case 'forest':
        return const Color(0xFF5CB85C);
      case 'mountain':
        return const Color(0xFF7B68EE);
      case 'castle':
        return const Color(0xFFE67E22);
      default:
        return const Color(0xFF4A90E2);
    }
  }
}
