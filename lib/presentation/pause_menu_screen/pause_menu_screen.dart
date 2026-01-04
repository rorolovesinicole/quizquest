import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/menu_option_widget.dart';
import './widgets/settings_section_widget.dart';

/// Pause Menu - Dialog overlay for game controls and settings
///
/// Features:
/// - Translucent overlay with blurred background
/// - Vertically stacked menu options with large touch targets
/// - Inline settings expansion with audio and accessibility controls
/// - Progress loss warnings for destructive actions
/// - Tap-outside-to-dismiss functionality
/// - Haptic feedback for all interactions
class PauseMenuScreen extends StatefulWidget {
  final String sourceScreen;
  
  const PauseMenuScreen({
    super.key,
    this.sourceScreen = 'unknown',
  });

  /// Show the pause menu as a dialog overlay
  static Future<void> show(BuildContext context, {String sourceScreen = 'unknown'}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => PauseMenuScreen(sourceScreen: sourceScreen),
    );
  }

  @override
  State<PauseMenuScreen> createState() => _PauseMenuScreenState();
}

class _PauseMenuScreenState extends State<PauseMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _showSettings = false;
  double _musicVolume = 0.7;
  double _soundEffectsVolume = 0.8;
  double _textSize = 1.0;
  bool _reducedMotion = false;
  bool _showTimer = true;
  bool _hintsAvailable = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismissModal() {
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _handleResumeGame() {
    HapticFeedback.mediumImpact();
    _dismissModal();
  }

  void _handleRestartLevel() {
    HapticFeedback.mediumImpact();
    _showConfirmationDialog(
      title: 'Restart Level?',
      message: 'Your current progress in this level will be lost.',
      confirmText: 'Restart',
      onConfirm: () {
        Navigator.of(context).pop(); // Close confirmation dialog
        Navigator.of(context).pop(); // Close pause menu
        Navigator.pushReplacementNamed(context, AppRoutes.quizGameplay);
      },
    );
  }

  void _handleQuitToMap() {
    HapticFeedback.mediumImpact();
    _showConfirmationDialog(
      title: 'Quit to Map?',
      message: 'Your progress in this level will be lost.',
      confirmText: 'Quit',
      onConfirm: () {
        Navigator.of(context).pop(); // Close confirmation dialog
        Navigator.of(context).pop(); // Close pause menu
        Navigator.pushReplacementNamed(context, AppRoutes.gameWorldMap);
      },
    );
  }

  void _handleMainMenu() {
    HapticFeedback.mediumImpact();
    _showConfirmationDialog(
      title: 'Return to Main Menu?',
      message: 'Your progress in this level will be lost.',
      confirmText: 'Main Menu',
      onConfirm: () {
        Navigator.of(context).pop(); // Close confirmation dialog
        Navigator.of(context).pop(); // Close pause menu
        Navigator.pushReplacementNamed(context, AppRoutes.mainMenu);
      },
    );
  }

  void _toggleSettings() {
    HapticFeedback.selectionClick();
    setState(() {
      _showSettings = !_showSettings;
    });
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      child: GestureDetector(
        onTap: _handleResumeGame,
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // Blurred background overlay
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),

              // Centered pause menu modal
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: () {}, // Prevent tap-through
                    child: Container(
                      width: 85.w,
                      constraints: BoxConstraints(
                        maxWidth: 400,
                        maxHeight: 80.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(theme),
                            Flexible(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    MenuOptionWidget(
                                      icon: 'play_arrow',
                                      label: 'Resume Game',
                                      isPrimary: true,
                                      onTap: _handleResumeGame,
                                    ),
                                    SizedBox(height: 1.h),
                                    MenuOptionWidget(
                                      icon: 'refresh',
                                      label: 'Restart Level',
                                      onTap: _handleRestartLevel,
                                      showWarning: true,
                                    ),
                                    SizedBox(height: 1.h),
                                    MenuOptionWidget(
                                      icon: 'settings',
                                      label: 'Settings',
                                      onTap: _toggleSettings,
                                      isExpanded: _showSettings,
                                    ),
                                    if (_showSettings) ...[
                                      SizedBox(height: 1.h),
                                      SettingsSectionWidget(
                                        musicVolume: _musicVolume,
                                        soundEffectsVolume: _soundEffectsVolume,
                                        textSize: _textSize,
                                        reducedMotion: _reducedMotion,
                                        showTimer: _showTimer,
                                        hintsAvailable: _hintsAvailable,
                                        onMusicVolumeChanged: (value) {
                                          setState(() => _musicVolume = value);
                                        },
                                        onSoundEffectsVolumeChanged: (value) {
                                          setState(() => _soundEffectsVolume = value);
                                        },
                                        onTextSizeChanged: (value) {
                                          setState(() => _textSize = value);
                                        },
                                        onReducedMotionChanged: (value) {
                                          setState(() => _reducedMotion = value);
                                        },
                                        onShowTimerChanged: (value) {
                                          setState(() => _showTimer = value);
                                        },
                                        onHintsAvailableChanged: (value) {
                                          setState(() => _hintsAvailable = value);
                                        },
                                      ),
                                    ],
                                    SizedBox(height: 1.h),
                                    MenuOptionWidget(
                                      icon: 'map',
                                      label: 'Quit to Map',
                                      onTap: _handleQuitToMap,
                                      showWarning: true,
                                    ),
                                    SizedBox(height: 1.h),
                                    MenuOptionWidget(
                                      icon: 'home',
                                      label: 'Main Menu',
                                      onTap: _handleMainMenu,
                                      showWarning: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'pause_circle',
            color: theme.colorScheme.primary,
            size: 32,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game Paused',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Your progress is saved',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _handleResumeGame,
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            tooltip: 'Resume',
          ),
        ],
      ),
    );
  }
}
