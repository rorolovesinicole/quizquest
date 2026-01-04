import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Action buttons widget for Main Menu Screen
///
/// Displays primary and secondary action buttons with appropriate styling
class ActionButtonsWidget extends StatelessWidget {
  final bool hasSavedProgress;
  final VoidCallback onContinueAdventure;
  final VoidCallback onNewGame;
  final VoidCallback onSettings;
  final VoidCallback onAchievements;

  const ActionButtonsWidget({
    super.key,
    required this.hasSavedProgress,
    required this.onContinueAdventure,
    required this.onNewGame,
    required this.onSettings,
    required this.onAchievements,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Continue Adventure button (only if saved progress exists)
        if (hasSavedProgress) ...[
          _buildPrimaryButton(
            context,
            label: 'Continue Adventure',
            icon: 'play_arrow',
            onPressed: onContinueAdventure,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // New Game button
        _buildPrimaryButton(
          context,
          label: 'New Game',
          icon: 'add_circle_outline',
          onPressed: onNewGame,
          gradient: hasSavedProgress
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.secondary,
                    theme.colorScheme.secondaryContainer,
                  ],
                )
              : LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
        ),

        const SizedBox(height: 24),

        // Secondary buttons row
        Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(
                context,
                label: 'Settings',
                icon: 'settings',
                onPressed: onSettings,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSecondaryButton(
                context,
                label: 'Achievements',
                icon: 'emoji_events',
                onPressed: onAchievements,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required String label,
    required String icon,
    required VoidCallback onPressed,
    required Gradient gradient,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(iconName: icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context, {
    required String label,
    required String icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
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
