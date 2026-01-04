import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Individual zone widget representing a knowledge area in the game world
///
/// Features:
/// - Visual representation of zone theme (forest, mountain, castle)
/// - Level nodes with completion status
/// - Lock/unlock visual indicators
/// - Star ratings and knowledge gem counts
class WorldMapZoneWidget extends StatelessWidget {
  final Map<String, dynamic> zoneData;
  final Function(Map<String, dynamic> levelData) onLevelTap;
  final bool isUnlocked;

  const WorldMapZoneWidget({
    super.key,
    required this.zoneData,
    required this.onLevelTap,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 76.w,
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zone header with theme icon and title
          _buildZoneHeader(theme),

          SizedBox(height: 0.8.h),

          // Zone background container with levels
          _buildZoneContainer(theme),
        ],
      ),
    );
  }

  Widget _buildZoneHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isUnlocked
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Zone theme icon
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: zoneData['icon'] as String,
              color: isUnlocked
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              size: 24,
            ),
          ),

          SizedBox(width: 3.w),

          // Zone title and level count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zoneData['name'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isUnlocked
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${zoneData['totalLevels']} Levels',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isUnlocked
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),

          // Lock indicator
          if (!isUnlocked)
            CustomIconWidget(
              iconName: 'lock',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildZoneContainer(ThemeData theme) {
    final levels = zoneData['levels'] as List<Map<String, dynamic>>;

    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUnlocked
              ? [
                  _getZoneColor(
                    zoneData['theme'] as String,
                  ).withValues(alpha: 0.2),
                  _getZoneColor(
                    zoneData['theme'] as String,
                  ).withValues(alpha: 0.1),
                ]
              : [
                  theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  theme.colorScheme.onSurface.withValues(alpha: 0.02),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? _getZoneColor(
                  zoneData['theme'] as String,
                ).withValues(alpha: 0.3)
              : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Regular levels (6 levels - 5 regular + 1 boss)
          ...List.generate(
            6,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 0.8.h),
              child: index < 5 
                  ? _buildLevelNode(theme, levels[index], index + 1)
                  : _buildBossLevelNode(theme, levels[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelNode(
    ThemeData theme,
    Map<String, dynamic> levelData,
    int levelNumber,
  ) {
    final isCompleted = levelData['isCompleted'] as bool;
    final isLocked = levelData['isLocked'] as bool;
    final stars = levelData['stars'] as int;
    final gems = levelData['gemsCollected'] as int;

    return GestureDetector(
      onTap: () => onLevelTap(levelData),
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: isCompleted
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Level number badge
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$levelNumber',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isCompleted
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 2.w),

              // Level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelData['title'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isCompleted) ...[
                      SizedBox(height: 0.3.h),
                      Row(
                        children: [
                          // Star rating
                          ...List.generate(
                            3,
                            (index) => Padding(
                              padding: EdgeInsets.only(right: 1.w),
                              child: CustomIconWidget(
                                iconName: index < stars
                                    ? 'star'
                                    : 'star_border',
                                color: index < stars
                                    ? const Color(0xFFF0AD4E)
                                    : theme.colorScheme.onSurfaceVariant,
                                size: 16,
                              ),
                            ),
                          ),

                          SizedBox(width: 1.5.w),

                          // Gems collected
                          CustomIconWidget(
                            iconName: 'diamond',
                            color: theme.colorScheme.tertiary,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '$gems',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ] else if (!isLocked) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        'Tap to start',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status icon
              if (isLocked)
                CustomIconWidget(
                  iconName: 'lock',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                )
              else if (isCompleted)
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: theme.colorScheme.primary,
                  size: 24,
                )
              else
                CustomIconWidget(
                  iconName: 'play_circle_outline',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBossLevelNode(ThemeData theme, Map<String, dynamic> bossData) {
    final isCompleted = bossData['isCompleted'] as bool;
    final isLocked = bossData['isLocked'] as bool;
    final stars = bossData['stars'] as int;

    return GestureDetector(
      onTap: () => onLevelTap(bossData),
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCompleted
                  ? [
                      theme.colorScheme.primary.withValues(alpha: 0.3),
                      theme.colorScheme.secondary.withValues(alpha: 0.3),
                    ]
                  : [
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      theme.colorScheme.secondaryContainer.withValues(
                        alpha: 0.5,
                      ),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Boss icon
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.onPrimary,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'emoji_events',
                    color: theme.colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Boss level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BOSS LEVEL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      bossData['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isCompleted) ...[
                      SizedBox(height: 0.8.h),
                      Row(
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: EdgeInsets.only(right: 1.w),
                            child: CustomIconWidget(
                              iconName: index < stars ? 'star' : 'star_border',
                              color: index < stars
                                  ? const Color(0xFFF0AD4E)
                                  : theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ] else if (!isLocked) ...[
                      SizedBox(height: 0.3.h),
                      Text(
                        'Complete all levels to unlock',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status icon
              if (isLocked)
                CustomIconWidget(
                  iconName: 'lock',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                )
              else if (isCompleted)
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: theme.colorScheme.primary,
                  size: 28,
                )
              else
                CustomIconWidget(
                  iconName: 'play_circle_outline',
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
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
