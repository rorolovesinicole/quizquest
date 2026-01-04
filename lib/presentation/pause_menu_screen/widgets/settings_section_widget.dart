import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Settings section widget for pause menu
///
/// Features:
/// - Audio controls with volume sliders
/// - Accessibility options (text size, reduced motion)
/// - Gameplay preferences (timer visibility, hint availability)
/// - Inline expansion within pause menu
class SettingsSectionWidget extends StatelessWidget {
  const SettingsSectionWidget({
    super.key,
    required this.musicVolume,
    required this.soundEffectsVolume,
    required this.textSize,
    required this.reducedMotion,
    required this.showTimer,
    required this.hintsAvailable,
    required this.onMusicVolumeChanged,
    required this.onSoundEffectsVolumeChanged,
    required this.onTextSizeChanged,
    required this.onReducedMotionChanged,
    required this.onShowTimerChanged,
    required this.onHintsAvailableChanged,
  });

  final double musicVolume;
  final double soundEffectsVolume;
  final double textSize;
  final bool reducedMotion;
  final bool showTimer;
  final bool hintsAvailable;
  final ValueChanged<double> onMusicVolumeChanged;
  final ValueChanged<double> onSoundEffectsVolumeChanged;
  final ValueChanged<double> onTextSizeChanged;
  final ValueChanged<bool> onReducedMotionChanged;
  final ValueChanged<bool> onShowTimerChanged;
  final ValueChanged<bool> onHintsAvailableChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(theme, 'Audio Controls', 'volume_up'),
          SizedBox(height: 1.5.h),
          _buildVolumeSlider(theme, 'Music', musicVolume, onMusicVolumeChanged),
          SizedBox(height: 1.h),
          _buildVolumeSlider(
            theme,
            'Sound Effects',
            soundEffectsVolume,
            onSoundEffectsVolumeChanged,
          ),
          SizedBox(height: 2.h),
          _buildSectionHeader(theme, 'Accessibility', 'accessibility'),
          SizedBox(height: 1.5.h),
          _buildTextSizeSlider(theme),
          SizedBox(height: 1.h),
          _buildToggleOption(
            theme,
            'Reduced Motion',
            reducedMotion,
            onReducedMotionChanged,
          ),
          SizedBox(height: 2.h),
          _buildSectionHeader(theme, 'Gameplay', 'gamepad'),
          SizedBox(height: 1.5.h),
          _buildToggleOption(
            theme,
            'Show Timer',
            showTimer,
            onShowTimerChanged,
          ),
          SizedBox(height: 1.h),
          _buildToggleOption(
            theme,
            'Hints Available',
            hintsAvailable,
            onHintsAvailableChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String icon) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(width: 2.w),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeSlider(
    ThemeData theme,
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.primary.withValues(
              alpha: 0.2,
            ),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.selectionClick();
              onChanged(newValue);
            },
            min: 0,
            max: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTextSizeSlider(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Text Size',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              textSize == 0.8
                  ? 'Small'
                  : textSize == 1.0
                  ? 'Medium'
                  : 'Large',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.primary.withValues(
              alpha: 0.2,
            ),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: textSize,
            onChanged: (newValue) {
              HapticFeedback.selectionClick();
              onTextSizeChanged(newValue);
            },
            min: 0.8,
            max: 1.2,
            divisions: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption(
    ThemeData theme,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) {
            HapticFeedback.selectionClick();
            onChanged(newValue);
          },
          activeThumbColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
