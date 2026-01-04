import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Menu option widget for pause menu
///
/// Features:
/// - Large touch target for easy interaction
/// - Icon and label with optional warning indicator
/// - Primary action styling for resume button
/// - Expansion indicator for settings option
/// - Haptic feedback on interaction
class MenuOptionWidget extends StatelessWidget {
  const MenuOptionWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.showWarning = false,
    this.isExpanded = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool showWarning;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: isPrimary
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isPrimary ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? theme.colorScheme.primary
                      : showWarning
                      ? theme.colorScheme.error.withValues(alpha: 0.1)
                      : theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: icon,
                  color: isPrimary
                      ? theme.colorScheme.onPrimary
                      : showWarning
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isPrimary
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isPrimary
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (showWarning) ...[
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'warning',
                            color: theme.colorScheme.error,
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              'Progress will be lost',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (icon == 'settings')
                CustomIconWidget(
                  iconName: isExpanded ? 'expand_less' : 'expand_more',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
