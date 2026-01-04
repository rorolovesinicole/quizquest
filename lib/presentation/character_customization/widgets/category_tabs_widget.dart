import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Category Tabs Widget
///
/// Displays horizontal scrolling category tabs for customization options
/// Features:
/// - Thumb-friendly sizing
/// - Smooth sliding animations
/// - Clear active state indicators
/// - Icon + label design
class CategoryTabsWidget extends StatelessWidget {
  final TabController controller;
  final int selectedIndex;

  const CategoryTabsWidget({
    super.key,
    required this.controller,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 8.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: false,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.6,
        ),
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelMedium,
        tabs: [
          _buildTab(theme, 'Hair', 'face', 0),
          _buildTab(theme, 'Face', 'sentiment_satisfied', 1),
          _buildTab(theme, 'Clothing', 'checkroom', 2),
          _buildTab(theme, 'Accessories', 'watch', 3),
        ],
      ),
    );
  }

  Widget _buildTab(ThemeData theme, String label, String iconName, int index) {
    final isSelected = selectedIndex == index;

    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 24,
          ),
          SizedBox(height: 0.5.h),
          Text(label),
        ],
      ),
    );
  }
}
