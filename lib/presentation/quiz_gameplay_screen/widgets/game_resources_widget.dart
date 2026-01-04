import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Game resources widget showing gems, power-ups, and hints
class GameResourcesWidget extends StatelessWidget {
  final int collectedGems;
  final int availableHints;
  final bool hasExtraTime;
  final bool hasEliminateOption;
  final VoidCallback onUseHint;
  final VoidCallback onUseExtraTime;
  final VoidCallback onUseEliminateOption;

  const GameResourcesWidget({
    super.key,
    required this.collectedGems,
    required this.availableHints,
    required this.hasExtraTime,
    required this.hasEliminateOption,
    required this.onUseHint,
    required this.onUseExtraTime,
    required this.onUseEliminateOption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            SizedBox(height: 2.h),

            Row(
              children: [
                // Knowledge gems display
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentLight.withValues(alpha: 0.2),
                          AppTheme.warningLight.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentLight.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'diamond',
                          color: AppTheme.accentLight,
                          size: 24,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '$collectedGems',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.accentLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Gems',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Power-ups row
            Row(
              children: [
                // Hint button
                Expanded(
                  child: _PowerUpButton(
                    icon: 'lightbulb',
                    label: 'Hint',
                    count: availableHints,
                    isAvailable: availableHints > 0,
                    color: AppTheme.warningLight,
                    onTap: availableHints > 0 ? onUseHint : null,
                  ),
                ),

                SizedBox(width: 2.w),

                // Extra time button
                Expanded(
                  child: _PowerUpButton(
                    icon: 'add_alarm',
                    label: 'Time',
                    count: hasExtraTime ? 1 : 0,
                    isAvailable: hasExtraTime,
                    color: colorScheme.primary,
                    onTap: hasExtraTime ? onUseExtraTime : null,
                  ),
                ),

                SizedBox(width: 2.w),

                // Eliminate option button
                Expanded(
                  child: _PowerUpButton(
                    icon: 'close',
                    label: 'Eliminate',
                    count: hasEliminateOption ? 1 : 0,
                    isAvailable: hasEliminateOption,
                    color: AppTheme.errorLight,
                    onTap: hasEliminateOption ? onUseEliminateOption : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerUpButton extends StatelessWidget {
  final String icon;
  final String label;
  final int count;
  final bool isAvailable;
  final Color color;
  final VoidCallback? onTap;

  const _PowerUpButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.isAvailable,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            HapticFeedback.mediumImpact();
            onTap!();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isAvailable
                ? color.withValues(alpha: 0.15)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAvailable
                  ? color.withValues(alpha: 0.4)
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomIconWidget(
                    iconName: icon,
                    color: isAvailable
                        ? color
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 28,
                  ),
                  if (count > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 5.w,
                          minHeight: 5.w,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isAvailable
                      ? color
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
