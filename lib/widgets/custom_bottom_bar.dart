import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Navigation item configuration for the bottom bar
enum CustomBottomBarItem {
  map(
    icon: Icons.map_outlined,
    activeIcon: Icons.map,
    label: 'Map',
    route: '/game-world-map-screen',
  ),
  progress(
    icon: Icons.analytics_outlined,
    activeIcon: Icons.analytics,
    label: 'Progress',
    route: '/progress-analytics',
  ),
  achievements(
    icon: Icons.emoji_events_outlined,
    activeIcon: Icons.emoji_events,
    label: 'Achievements',
    route: '/achievement-gallery',
  ),
  character(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Character',
    route: '/character-customization',
  );

  const CustomBottomBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}

/// Custom bottom navigation bar optimized for educational RPG gaming
///
/// Features:
/// - Thumb-zone optimized positioning for one-handed use
/// - Haptic feedback on navigation for tactile confirmation
/// - Smooth transitions with spring animations
/// - Platform-adaptive styling
/// - Accessibility support with semantic labels
///
/// Usage:
/// ```dart
/// Scaffold(
///   body: _pages[_currentIndex],
///   bottomNavigationBar: CustomBottomBar(
///     currentIndex: _currentIndex,
///     onTap: (index) {
///       setState(() => _currentIndex = index);
///     },
///   ),
/// )
/// ```
class CustomBottomBar extends StatefulWidget {
  /// Creates a custom bottom navigation bar
  ///
  /// [currentIndex] - Currently selected tab index (0-3)
  /// [onTap] - Callback when a navigation item is tapped
  /// [elevation] - Shadow elevation of the bar (default: 8.0)
  /// [enableHapticFeedback] - Enable haptic feedback on tap (default: true)
  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.elevation = 8.0,
    this.enableHapticFeedback = true,
  }) : assert(
         currentIndex >= 0 && currentIndex < 4,
         'currentIndex must be between 0 and 3',
       );

  final int currentIndex;
  final ValueChanged<int> onTap;
  final double elevation;
  final bool enableHapticFeedback;

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;

    // Spring animation for smooth transitions (300ms with 0.8 damping)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void didUpdateWidget(CustomBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;

    // Haptic feedback for tactile confirmation
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomNavTheme = theme.bottomNavigationBarTheme;

    return Container(
      decoration: BoxDecoration(
        color: bottomNavTheme.backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: widget.elevation,
            offset: Offset(0, -widget.elevation / 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              CustomBottomBarItem.values.length,
              (index) => _buildNavItem(
                context,
                CustomBottomBarItem.values[index],
                index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    CustomBottomBarItem item,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomNavTheme = theme.bottomNavigationBarTheme;
    final isSelected = widget.currentIndex == index;

    final selectedColor =
        bottomNavTheme.selectedItemColor ?? colorScheme.primary;
    final unselectedColor =
        bottomNavTheme.unselectedItemColor ??
        colorScheme.onSurface.withValues(alpha: 0.6);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(index),
          borderRadius: BorderRadius.circular(12),
          splashColor: selectedColor.withValues(alpha: 0.1),
          highlightColor: selectedColor.withValues(alpha: 0.05),
          child: Semantics(
            label: '${item.label} tab',
            selected: isSelected,
            button: true,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with scale animation
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      final scale = isSelected
                          ? 1.0 + (_scaleAnimation.value * 0.1)
                          : 1.0;

                      return Transform.scale(
                        scale: scale,
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 24,
                          color: isSelected ? selectedColor : unselectedColor,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 4),

                  // Label with smooth color transition
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    style:
                        (isSelected
                            ? bottomNavTheme.selectedLabelStyle
                            : bottomNavTheme.unselectedLabelStyle) ??
                        theme.textTheme.labelSmall!.copyWith(
                          color: isSelected ? selectedColor : unselectedColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to easily navigate using CustomBottomBar items
extension CustomBottomBarNavigation on BuildContext {
  /// Navigate to a bottom bar item's route
  void navigateToBottomBarItem(CustomBottomBarItem item) {
    Navigator.pushNamed(this, item.route);
  }
}
