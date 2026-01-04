import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/game_state_service.dart';
import '../../services/question_service.dart';
import '../../presentation/pause_menu_screen/pause_menu_screen.dart';
import './widgets/answer_options_widget.dart';
import './widgets/feedback_overlay_widget.dart';
import './widgets/game_resources_widget.dart';
import './widgets/question_content_widget.dart';
import './widgets/timer_header_widget.dart';

/// Quiz Gameplay Screen - Immersive educational quiz interface
class QuizGameplayScreen extends StatefulWidget {
  const QuizGameplayScreen({super.key});

  @override
  State<QuizGameplayScreen> createState() => _QuizGameplayScreenState();
}

class _QuizGameplayScreenState extends State<QuizGameplayScreen>
    with TickerProviderStateMixin {
  // Game state
  int _currentQuestionIndex = 0;
  int _remainingSeconds = 60;
  int _collectedGems = 0;
  int _correctAnswers = 0;
  int _totalTimeSpent = 0;
  int _availableHints = 3;
  bool _hasExtraTime = true;
  bool _hasEliminateOption = true;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  bool _showFeedback = false;
  bool _isLoading = true;
  Timer? _timer;

  // Level info from route arguments
  String _programId = 'bsit';
  int _levelId = 1;
  String _levelTitle = 'Level 1';
  
  // Questions loaded from QuestionService
  List<Map<String, dynamic>> _quizQuestions = [];
  
  // Services
  final GameStateService _gameStateService = GameStateService();
  final QuestionService _questionService = QuestionService();

  // Animation controllers
  late AnimationController _questionTransitionController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    if (!_gameStateService.isInitialized) {
      await _gameStateService.initialize();
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      setState(() {
        _programId = args?['programId'] as String? ?? _gameStateService.currentProgram;
        if (_programId.isEmpty) _programId = 'bsit';
        _levelId = args?['levelId'] as int? ?? 1;
        _levelTitle = args?['levelTitle'] as String? ?? 'Level $_levelId';
        
        // Load power-ups from game state
        final powerUps = _gameStateService.powerUps;
        _availableHints = powerUps['hint'] ?? 3;
        _hasExtraTime = (powerUps['extra_time'] ?? 0) > 0;
        _hasEliminateOption = (powerUps['eliminate'] ?? 0) > 0;
        
        // Load questions for this program and level
        _quizQuestions = _questionService.getQuestionsForLevel(_programId, _levelId);
        _isLoading = false;
      });
      
      _startTimer();
    });
  }

  void _initializeAnimations() {
    _questionTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionTransitionController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _questionTransitionController, curve: Curves.easeOutCubic),
    );

    _questionTransitionController.forward();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && !_isAnswered) {
        setState(() {
          _remainingSeconds--;
          _totalTimeSpent++;
          if (_remainingSeconds <= 5) {
            HapticFeedback.lightImpact();
          }
        });
      } else if (_remainingSeconds == 0 && !_isAnswered) {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    setState(() {
      _isAnswered = true;
      _showFeedback = true;
    });
    HapticFeedback.heavyImpact();
  }

  void _handleAnswerSelection(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
    });

    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final isCorrect = index == (currentQuestion["correctIndex"] as int);

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      _particleController.forward(from: 0.0);
      setState(() {
        _collectedGems += (currentQuestion["points"] as int? ?? 10);
        _correctAnswers++;
      });
    } else {
      HapticFeedback.heavyImpact();
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showFeedback = true;
        });
      }
    });
  }

  void _handleContinue() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
        _showFeedback = false;
        _remainingSeconds = 60;
      });

      _questionTransitionController.reset();
      _questionTransitionController.forward();
      _startTimer();
    } else {
      _navigateToLevelComplete();
    }
  }

  void _navigateToLevelComplete() {
    _timer?.cancel();
    
    // Calculate stars based on accuracy
    final accuracy = _quizQuestions.isNotEmpty ? (_correctAnswers / _quizQuestions.length * 100) : 0.0;
    int stars = 1;
    if (accuracy >= 90) {
      stars = 3;
    } else if (accuracy >= 70) {
      stars = 2;
    }
    
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.levelComplete,
      arguments: {
        'programId': _programId,
        'levelId': _levelId,
        'levelTitle': _levelTitle,
        'starsEarned': stars,
        'accuracy': accuracy.round(),
        'timeTaken': _totalTimeSpent,
        'gemsCollected': _collectedGems,
        'correctAnswers': _correctAnswers,
        'totalQuestions': _quizQuestions.length,
      },
    );
  }

  void _handlePause() {
    _timer?.cancel();
    PauseMenuScreen.show(context, sourceScreen: 'quiz_gameplay').then((_) {
      if (!_isAnswered && mounted) {
        _startTimer();
      }
    });
  }

  void _handleUseHint() {
    if (_availableHints <= 0 || _isAnswered) return;

    setState(() {
      _availableHints--;
    });
    
    // Save hint usage
    _gameStateService.useHint();

    HapticFeedback.selectionClick();
    _showHintDialog();
  }

  void _handleUseExtraTime() {
    if (!_hasExtraTime || _isAnswered) return;

    setState(() {
      _hasExtraTime = false;
      _remainingSeconds += 30;
    });
    
    // Save power-up usage
    _gameStateService.usePowerUp('extra_time');

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('+30 seconds added!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleEliminateOption() {
    if (!_hasEliminateOption || _isAnswered) return;
    
    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final correctIndex = currentQuestion["correctIndex"] as int;
    final options = currentQuestion["options"] as List;
    
    if (options.length <= 2) return;

    setState(() {
      _hasEliminateOption = false;
    });
    
    // Save power-up usage
    _gameStateService.usePowerUp('eliminate');

    // Find two wrong answers to eliminate
    final wrongIndices = <int>[];
    for (int i = 0; i < options.length; i++) {
      if (i != correctIndex) wrongIndices.add(i);
    }
    wrongIndices.shuffle();
    final eliminatedIndices = wrongIndices.take(2).toList();
    
    currentQuestion['eliminatedIndices'] = eliminatedIndices;

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Two wrong answers eliminated!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showHintDialog() {
    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final correctIndex = currentQuestion["correctIndex"] as int;
    final options = currentQuestion["options"] as List;
    final correctAnswer = options[correctIndex];
    
    // Show a hint that narrows down the answer
    String hint = "The correct answer starts with '${correctAnswer.toString().substring(0, 1)}'";
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Hint'),
          ],
        ),
        content: Text(hint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _questionTransitionController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading || _quizQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 2.h),
              Text('Loading questions...', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _quizQuestions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Timer and progress header
                TimerHeaderWidget(
                  remainingSeconds: _remainingSeconds,
                  currentQuestion: _currentQuestionIndex + 1,
                  totalQuestions: _quizQuestions.length,
                  onPause: _handlePause,
                ),

                // Game resources bar
                GameResourcesWidget(
                  collectedGems: _collectedGems,
                  availableHints: _availableHints,
                  hasExtraTime: _hasExtraTime,
                  hasEliminateOption: _hasEliminateOption,
                  onUseHint: _handleUseHint,
                  onUseExtraTime: _handleUseExtraTime,
                  onUseEliminateOption: _handleEliminateOption,
                ),

                // Question content
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: QuestionContentWidget(
                        questionText: currentQuestion['question'] as String,
                        imageUrl: currentQuestion['imageUrl'] as String?,
                        imageSemanticLabel: currentQuestion['imageSemanticLabel'] as String?,
                        questionType: currentQuestion['type'] as String? ?? 'multiple_choice',
                      ),
                    ),
                  ),
                ),

                // Answer options
                AnswerOptionsWidget(
                  options: List<String>.from(currentQuestion["options"] as List),
                  selectedIndex: _selectedAnswerIndex,
                  correctIndex: currentQuestion["correctIndex"] as int,
                  isAnswered: _isAnswered,
                  eliminatedIndices: currentQuestion['eliminatedIndices'] as List<int>? ?? [],
                  onOptionSelected: _handleAnswerSelection,
                ),

                SizedBox(height: 2.h),
              ],
            ),

            // Feedback overlay
            if (_showFeedback)
              FeedbackOverlayWidget(
                isCorrect: _selectedAnswerIndex == (currentQuestion["correctIndex"] as int),
                explanation: currentQuestion["explanation"] as String? ?? '',
                onContinue: _handleContinue,
              ),
          ],
        ),
      ),
    );
  }
}
