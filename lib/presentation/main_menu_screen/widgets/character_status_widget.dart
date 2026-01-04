import 'package:flutter/material.dart';

import 'package:fluttermoji/fluttermoji.dart';
import '../../../core/app_export.dart';

/// Character status widget for Main Menu Screen
///
/// Displays character avatar, level, and knowledge gems with long-press customization
class CharacterStatusWidget extends StatelessWidget {
  final int currentLevel;
  final int knowledgeGems;
  final VoidCallback onAvatarLongPress;

  const CharacterStatusWidget({
    super.key,
    required this.currentLevel,
    required this.knowledgeGems,
    required this.onAvatarLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with long-press gesture
          GestureDetector(
            onLongPress: onAvatarLongPress,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: FluttermojiCircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.surface,
                    ),
                  ),
                ),

                // Level badge
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
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
                      'Lv $currentLevel',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Long-press hint
          Text(
            'Long press to customize',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                icon: 'trending_up',
                label: 'Level',
                value: currentLevel.toString(),
                color: theme.colorScheme.primary,
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                context,
                icon: 'diamond',
                label: 'Gems',
                value: knowledgeGems.toString(),
                color: theme.colorScheme.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(iconName: icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
