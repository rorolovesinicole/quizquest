import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Customization Grid Widget
///
/// Displays grid of customization items with status indicators
/// Features:
/// - Clear locked/owned status
/// - Checkmark overlay for selected items
/// - Unlock requirements display
/// - Gem cost indicators
class CustomizationGridWidget extends StatelessWidget {
  final List<dynamic> items;
  final String currentSelection;
  final Function(Map<String, dynamic>) onItemSelected;

  const CustomizationGridWidget({
    super.key,
    required this.items,
    required this.currentSelection,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index] as Map<String, dynamic>;
        return _buildGridItem(context, theme, item);
      },
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> item,
  ) {
    final isLocked = item['locked'] == true;
    final isOwned = item['owned'] == true;
    final isSelected = item['id'] == currentSelection;
    final cost = item['cost'] as int?;

    return GestureDetector(
      onTap: () => onItemSelected(item),
      onLongPress: isLocked ? () => onItemSelected(item) : null,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Stack(
          children: [
            // Item image
            ClipRRect(
              borderRadius: BorderRadius.circular(3.w),
              child: ColorFiltered(
                colorFilter: isLocked
                    ? ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.6),
                        BlendMode.darken,
                      )
                    : const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      ),
                child: CustomImageWidget(
                  imageUrl: item['image'] as String,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  semanticLabel: item['semanticLabel'] as String,
                ),
              ),
            ),

            // Lock overlay
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'lock',
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

            // Selected checkmark
            if (isSelected && !isLocked)
              Positioned(
                top: 1.w,
                right: 1.w,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'check',
                    color: theme.colorScheme.onPrimary,
                    size: 16,
                  ),
                ),
              ),

            // Cost indicator
            if (cost != null && cost > 0 && !isOwned)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(3.w),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'diamond',
                        color: const Color(0xFF6B73FF),
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        cost.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Item name
            Positioned(
              bottom: cost != null && cost > 0 && !isOwned ? 4.h : 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(3.w),
                  ),
                ),
                child: Text(
                  item['name'] as String,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
