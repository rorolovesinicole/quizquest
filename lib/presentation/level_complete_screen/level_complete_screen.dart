import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/game_state_service.dart';
import './widgets/achievements_widget.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/confetti_animation_widget.dart';
import './widgets/performance_metrics_widget.dart';
import './widgets/progress_bar_widget.dart';
import './widgets/star_rating_widget.dart';

/// Level Complete Screen - Celebrates player achievements and saves progress
class LevelCompleteScreen extends StatefulWidget {
  const LevelCompleteScreen({super.key});

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with TickerProviderStateMixin {
  // Data loaded from route arguments
  String _programId = 'bsit';
  int _levelId = 1;
  String _levelTitle = 'Level 1';
  int _starsEarned = 2;
  double _accuracy = 70.0;
  int _timeTaken = 120;
  int _gemsCollected = 10;
  int _correctAnswers = 7;
  int _totalQuestions = 10;
  
  final int _totalLevels = 18; // 6 levels x 3 zones
  String _zoneName = 'Foundational Concepts';
  String _programName = 'BSIT Program';
  
  final GameStateService _gameStateService = GameStateService();

  final List<Map<String, dynamic>> _achievements = [];
  bool _showConfetti = true;
  bool _showScoringBreakdown = false;
  bool _isLoading = true;
  bool _progressSaved = false;

  @override
  void initState() {
    super.initState();
    _loadDataAndSaveProgress();
  }

  Future<void> _loadDataAndSaveProgress() async {
    if (!_gameStateService.isInitialized) {
      await _gameStateService.initialize();
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      setState(() {
        _programId = args?['programId'] as String? ?? _gameStateService.currentProgram;
        if (_programId.isEmpty) _programId = 'bsit';
        _levelId = args?['levelId'] as int? ?? 1;
        _levelTitle = args?['levelTitle'] as String? ?? 'Level $_levelId';
        _starsEarned = args?['starsEarned'] as int? ?? 2;
        _accuracy = (args?['accuracy'] as int?)?.toDouble() ?? 70.0;
        _timeTaken = args?['timeTaken'] as int? ?? 120;
        _gemsCollected = args?['gemsCollected'] as int? ?? 10;
        _correctAnswers = args?['correctAnswers'] as int? ?? 7;
        _totalQuestions = args?['totalQuestions'] as int? ?? 10;
        
        _programName = _getProgramDisplayName(_programId);
        _zoneName = _getZoneName(_levelId);
        
        // Generate achievements based on performance
        _generateAchievements();
        
        _isLoading = false;
      });
      
      // Save progress to GameStateService
      if (!_progressSaved) {
        await _saveProgress();
        _progressSaved = true;
      }
      
      _triggerCelebrationEffects();
    });
  }

  String _getProgramDisplayName(String programId) {
    const programNames = {
      'bsit': 'BSIT Program',
      'bsba': 'BSBA Program',
      'bsed': 'BSED Program',
      'beed': 'BEED Program',
      'bsa': 'BSA Program',
      'bshm': 'BSHM Program',
      'bscs': 'BSCS Program',
      'bscpe': 'BSCpE Program',
      'ahm': 'AHM Program',
    };
    return programNames[programId.toLowerCase()] ?? 'Program';
  }

  String _getZoneName(int levelId) {
    final zoneIndex = (levelId - 1) ~/ 6;
    const zones = ['Foundational Concepts', 'Core Principles', 'Advanced Applications'];
    return zones[zoneIndex.clamp(0, 2)];
  }

  void _generateAchievements() {
    _achievements.clear();
    
    if (_accuracy >= 90) {
      _achievements.add({
        "icon": "workspace_premium",
        "title": "Perfect Scholar",
        "description": "Achieved 90%+ accuracy",
      });
    }
    
    if (_timeTaken < 180) {
      _achievements.add({
        "icon": "speed",
        "title": "Speed Demon",
        "description": "Completed level in under 3 minutes",
      });
    }
    
    if (_starsEarned == 3) {
      _achievements.add({
        "icon": "star",
        "title": "Star Collector",
        "description": "Earned all 3 stars",
      });
    }
  }

  Future<void> _saveProgress() async {
    // Calculate XP based on performance
    final xpEarned = (_accuracy * 10 + _gemsCollected * 2 + (_starsEarned * 50)).round();
    
    await _gameStateService.completeLevelWithResults(
      programId: _programId,
      levelId: _levelId,
      stars: _starsEarned,
      gems: _gemsCollected,
      xp: xpEarned,
    );
  }

  void _triggerCelebrationEffects() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showConfetti = false);
      }
    });
  }

  void _showScoringBreakdownModal() {
    HapticFeedback.lightImpact();
    setState(() => _showScoringBreakdown = true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildScoringBreakdownModal(),
    ).then((_) {
      if (mounted) {
        setState(() => _showScoringBreakdown = false);
      }
    });
  }

  Widget _buildScoringBreakdownModal() {
    final theme = Theme.of(context);
    final totalPoints = (_accuracy * 10 + _gemsCollected * 10 + _starsEarned * 50).round();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          Text('Score Breakdown', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 2.h),
          _buildBreakdownItem('Accuracy Bonus', '${(_accuracy * 10).round()} pts', '${_accuracy.round()}% accuracy'),
          _buildBreakdownItem('Gems Collected', '${_gemsCollected * 10} pts', '$_gemsCollected gems × 10'),
          _buildBreakdownItem('Star Bonus', '${_starsEarned * 50} pts', '$_starsEarned stars × 50'),
          Divider(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Score', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text('$totalPoints pts', style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String value, String description) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                Text(description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.tertiary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _handleContinueAdventure() {
    HapticFeedback.lightImpact();
    
    if (_levelId == _totalLevels) {
      Navigator.pushReplacementNamed(context, AppRoutes.programCertificate, arguments: {
        'programName': _programName,
        'programId': _programId,
        'completionDate': DateTime.now(),
        'totalScore': (_accuracy * 10 + _gemsCollected * 10 + _starsEarned * 50).round(),
        'starsEarned': _gameStateService.getTotalStars(_programId),
        'totalStars': _totalLevels * 3,
        'gemsCollected': _gameStateService.totalGems,
        'accuracy': _accuracy,
      });
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.gameWorldMap, arguments: {
        'programId': _programId,
      });
    }
  }

  void _handleReplayLevel() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, AppRoutes.quizGameplay, arguments: {
      'programId': _programId,
      'levelId': _levelId,
      'levelTitle': _levelTitle,
    });
  }

  void _handleShareScore() {
    HapticFeedback.lightImpact();
    final totalPoints = (_accuracy * 10 + _gemsCollected * 10 + _starsEarned * 50).round();
    Share.share(
      'I just completed $_levelTitle in QuizQuest Academy with $_starsEarned stars and $totalPoints points! 🎉',
      subject: 'QuizQuest Academy Score',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final timeDuration = Duration(seconds: _timeTaken);
    final timeString = '${timeDuration.inMinutes}:${(timeDuration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                children: [
                  // Header
                  Text('Level Complete!', style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                  SizedBox(height: 1.h),
                  Text(_levelTitle, style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
                  SizedBox(height: 3.h),

                  // Star Rating
                  StarRatingWidget(
                    stars: _starsEarned, 
                    onLongPress: _showScoringBreakdownModal,
                  ),
                  SizedBox(height: 3.h),

                  // Performance Metrics
                  PerformanceMetricsWidget(
                    accuracy: _accuracy,
                    timeTaken: Duration(seconds: _timeTaken),
                    gemsCollected: _gemsCollected,
                    bonusPoints: (_starsEarned * 50), // Calculating bonus points
                  ),
                  SizedBox(height: 3.h),

                  // Progress Bar
                  ProgressBarWidget(
                    currentLevel: _levelId,
                    totalLevels: _totalLevels,
                    zoneName: _zoneName,
                  ),
                  SizedBox(height: 3.h),

                  // Achievements
                  if (_achievements.isNotEmpty) ...[
                    AchievementsWidget(
                      achievements: _achievements,
                      nextLevelRequirement: "Complete next level to unlock more!", // meaningful default
                    ),
                    SizedBox(height: 3.h),
                  ],

                  // Action Buttons
                  ActionButtonsWidget(
                    onContinue: _handleContinueAdventure,
                    onReplay: _handleReplayLevel,
                    onShare: _handleShareScore,
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),

          // Confetti
          if (_showConfetti)
            Positioned.fill(
              child: IgnorePointer(child: ConfettiAnimationWidget(isPlaying: _showConfetti)),
            ),
        ],
      ),
    );
  }
}
