import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/game_state_service.dart';
import '../../presentation/pause_menu_screen/pause_menu_screen.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/character_status_widget.dart';
import './widgets/main_menu_header_widget.dart';

/// Main Menu Screen - Central hub for QuizQuest Academy
///
/// Features:
/// - Continue Adventure (if saved progress exists)
/// - New Game initialization
/// - Settings and Achievements access
/// - Character avatar display with quick customization
/// - Background music with volume controls
/// - Platform-specific interactions (haptic feedback, ripple effects)
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Player data loaded from GameStateService
  bool _hasSavedProgress = false;
  int _currentLevel = 1;
  int _knowledgeGems = 50;
  String _characterAvatar =
      "https://api.dicebear.com/7.x/avataaars/png?seed=Felix&backgroundColor=b6e3f4";

  final GameStateService _gameStateService = GameStateService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPlayerData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  Future<void> _loadPlayerData() async {
    // Ensure service is initialized
    if (!_gameStateService.isInitialized) {
      await _gameStateService.initialize();
    }
    
    // Load player data from persistence
    if (mounted) {
      setState(() {
        _hasSavedProgress = _gameStateService.hasSavedProgress;
        _currentLevel = _gameStateService.currentLevel;
        _knowledgeGems = _gameStateService.totalGems;
        _characterAvatar = _gameStateService.characterAvatar;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleContinueAdventure() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/game-world-map-screen');
  }

  void _handleNewGame() {
    HapticFeedback.lightImpact();
    _showNewGameDialog();
  }

  void _handleSettings() {
    HapticFeedback.lightImpact();
    PauseMenuScreen.show(context, sourceScreen: 'main_menu');
  }

  void _handleAchievements() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRoutes.achievementGallery);
  }

  void _handleCharacterCustomization() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, AppRoutes.characterCustomization);
  }

  void _showNewGameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Start New Adventure?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          _hasSavedProgress
              ? 'Starting a new game will overwrite your current progress. Are you sure you want to continue?'
              : 'Begin your educational journey through QuizQuest Academy!',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.programSelection);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.1),
              theme.colorScheme.tertiary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // Header with logo and title
                      MainMenuHeaderWidget(),

                      const SizedBox(height: 48),

                      // Action buttons
                      ActionButtonsWidget(
                        hasSavedProgress: _hasSavedProgress,
                        onContinueAdventure: _handleContinueAdventure,
                        onNewGame: _handleNewGame,
                        onSettings: _handleSettings,
                        onAchievements: _handleAchievements,
                      ),

                      const SizedBox(height: 48),

                      // Character status
                      CharacterStatusWidget(
                        characterAvatar: _characterAvatar,
                        currentLevel: _currentLevel,
                        knowledgeGems: _knowledgeGems,
                        onAvatarLongPress: _handleCharacterCustomization,
                      ),

                      const SizedBox(height: 24),

                      // Help button
                      _buildHelpButton(theme),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpButton(ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showHelpDialog();
          },
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: CustomIconWidget(
              iconName: 'help_outline',
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'school',
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text('How to Play', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem(
                context,
                'Choose Your Program',
                'Select from BSIT, BSBA, BSED, and more educational programs',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                context,
                'Explore the World Map',
                'Navigate through knowledge zones and unlock new areas',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                context,
                'Complete Quizzes',
                'Answer questions to earn knowledge gems and level up',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                context,
                'Earn Achievements',
                'Collect badges and unlock special rewards',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got It!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
    BuildContext context,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
