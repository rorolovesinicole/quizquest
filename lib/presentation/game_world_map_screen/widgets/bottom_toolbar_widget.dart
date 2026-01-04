import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Bottom toolbar with inventory, stats, and menu access
///
/// Features:
/// - Power-up inventory display
/// - Character stats summary
/// - Quick access to pause menu
class BottomToolbarWidget extends StatelessWidget {
  final Map<String, dynamic> playerStats;
  final List<Map<String, dynamic>> inventory;
  final VoidCallback onInventoryTap;
  final VoidCallback onStatsTap;
  final VoidCallback onMenuTap;

  const BottomToolbarWidget({
    super.key,
    required this.playerStats,
    required this.inventory,
    required this.onInventoryTap,
    required this.onStatsTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Inventory button
            _buildToolbarButton(
              theme,
              icon: 'backpack',
              label: 'Inventory',
              badge: inventory.length.toString(),
              onTap: onInventoryTap,
            ),

            // Stats button
            _buildToolbarButton(
              theme,
              icon: 'bar_chart',
              label: 'Stats',
              badge: null,
              onTap: onStatsTap,
            ),

            // Menu button
            _buildToolbarButton(
              theme,
              icon: 'menu',
              label: 'Menu',
              badge: null,
              onTap: onMenuTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(
    ThemeData theme, {
    required String icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Badge indicator
            if (badge != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  constraints: BoxConstraints(minWidth: 5.w, minHeight: 5.w),
                  child: Center(
                    child: Text(
                      badge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onError,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
