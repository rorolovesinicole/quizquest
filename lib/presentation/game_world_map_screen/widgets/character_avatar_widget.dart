import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:fluttermoji/fluttermoji.dart';
import '../../../core/app_export.dart';

/// Animated character avatar that moves along the completed path
///
/// Features:
/// - Walking animation states
/// - Position tracking on map
/// - Visual feedback for movement
class CharacterAvatarWidget extends StatefulWidget {
  final Map<String, dynamic> characterData;
  final double positionX;
  final double positionY;
  final bool isMoving;

  const CharacterAvatarWidget({
    super.key,
    required this.characterData,
    required this.positionX,
    required this.positionY,
    this.isMoving = false,
  });

  @override
  State<CharacterAvatarWidget> createState() => _CharacterAvatarWidgetState();
}

class _CharacterAvatarWidgetState extends State<CharacterAvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isMoving) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CharacterAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMoving && !oldWidget.isMoving) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isMoving && oldWidget.isMoving) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: widget.positionX,
      top: widget.positionY,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Character avatar with level badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar container
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    border: Border.all(
                      color: theme.colorScheme.onPrimary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                      child: FluttermojiCircleAvatar(
                        radius: 8.w,
                        backgroundColor: Colors.transparent,
                      ),
                  ),
                ),

                // Level badge
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.onPrimary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Lv ${widget.characterData['level']}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onTertiary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

                // Movement indicator
                if (widget.isMoving)
                  Positioned(
                    top: -8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: 'directions_walk',
                          color: theme.colorScheme.onPrimary,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 1.h),

            // Character name
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outline, width: 1),
              ),
              child: Text(
                widget.characterData['name'] as String,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
