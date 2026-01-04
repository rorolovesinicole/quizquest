import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/game_state_service.dart';
import '../../presentation/pause_menu_screen/pause_menu_screen.dart';
import './widgets/bottom_toolbar_widget.dart';
import './widgets/character_avatar_widget.dart';
import './widgets/mini_map_widget.dart';
import './widgets/world_map_zone_widget.dart';

/// Game World Map Screen - Immersive 2D adventure navigation
class GameWorldMapScreen extends StatefulWidget {
  const GameWorldMapScreen({super.key});

  @override
  State<GameWorldMapScreen> createState() => _GameWorldMapScreenState();
}

class _GameWorldMapScreenState extends State<GameWorldMapScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TransformationController _transformationController =
      TransformationController();
  final GameStateService _gameStateService = GameStateService();

  late AnimationController _parallaxController;
  double _scrollOffset = 0.0;
  int _currentZoneIndex = 0;
  bool _isCharacterMoving = false;
  bool _isLoading = true;
  
  String _currentProgram = 'bsit';
  String _programName = 'BSIT Program';
  List<Map<String, dynamic>> _worldZones = [];
  Map<String, dynamic> _characterData = {};
  Map<String, dynamic> _playerStats = {};
  List<Map<String, dynamic>> _inventory = [];

  @override
  void initState() {
    super.initState();
    _parallaxController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _scrollController.addListener(_onScroll);
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    if (!_gameStateService.isInitialized) {
      await _gameStateService.initialize();
    }
    
    // Get program from route arguments or saved state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final programId = args?['programId'] as String? ?? _gameStateService.currentProgram;
      
      setState(() {
        _currentProgram = programId.isNotEmpty ? programId : 'bsit';
        _programName = _getProgramDisplayName(_currentProgram);
        _worldZones = _buildWorldZones(_currentProgram);
        _characterData = {
          'name': _gameStateService.playerName,
          'level': _gameStateService.currentLevel,
          'avatarUrl': _gameStateService.characterAvatar,
          'avatarDescription': 'Player character avatar',
        };
        _playerStats = {
          'totalXP': _gameStateService.totalXP,
          'currentLevel': _gameStateService.currentLevel,
          'gemsCollected': _gameStateService.totalGems,
          'powerUpsOwned': _gameStateService.powerUps.values.fold(0, (a, b) => a + b),
        };
        _inventory = _buildInventory();
        _isLoading = false;
      });
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

  List<Map<String, dynamic>> _buildWorldZones(String programId) {
    // Define zone themes and titles based on program
    final zoneConfigs = _getZoneConfigs(programId);
    
    return zoneConfigs.asMap().entries.map((entry) {
      final zoneIndex = entry.key;
      final config = entry.value;
      
      return {
        'id': zoneIndex + 1,
        'name': config['name'],
        'theme': config['theme'],
        'icon': config['icon'],
        'totalLevels': 6,
        'levels': List.generate(6, (levelIndex) {
          final globalLevelId = zoneIndex * 6 + levelIndex + 1;
          return _buildLevelData(programId, globalLevelId, config['levelTitles'][levelIndex]);
        }),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _getZoneConfigs(String programId) {
    // Program-specific zone configurations
    switch (programId.toLowerCase()) {
      case 'bsit':
        return [
          {'name': 'Programming Fundamentals', 'theme': 'forest', 'icon': 'park',
           'levelTitles': ['Introduction to Programming', 'Variables & Data Types', 'Control Structures', 'Functions & Methods', 'Arrays & Collections', 'Fundamentals Challenge']},
          {'name': 'Network Architecture', 'theme': 'mountain', 'icon': 'terrain',
           'levelTitles': ['Networking Basics', 'TCP/IP Protocol', 'Network Security', 'Wireless Networks', 'Cloud Computing', 'Network Mastery']},
          {'name': 'Database Systems', 'theme': 'castle', 'icon': 'castle',
           'levelTitles': ['Database Concepts', 'SQL Fundamentals', 'Data Modeling', 'Database Design', 'Advanced Queries', 'Database Expert']},
        ];
      case 'bsba':
        return [
          {'name': 'Business Foundations', 'theme': 'forest', 'icon': 'park',
           'levelTitles': ['Business Concepts', 'Management Basics', 'Organizational Structure', 'Business Ethics', 'Strategic Planning', 'Foundation Challenge']},
          {'name': 'Marketing Strategy', 'theme': 'mountain', 'icon': 'terrain',
           'levelTitles': ['Marketing Basics', 'Consumer Behavior', 'Brand Management', 'Digital Marketing', 'Market Research', 'Marketing Mastery']},
          {'name': 'Financial Management', 'theme': 'castle', 'icon': 'castle',
           'levelTitles': ['Financial Accounting', 'Budget Management', 'Investment Analysis', 'Risk Management', 'Financial Reporting', 'Finance Expert']},
        ];
      case 'bsed':
      case 'beed':
        return [
          {'name': 'Teaching Methods', 'theme': 'forest', 'icon': 'park',
           'levelTitles': ['Pedagogy Basics', 'Lesson Planning', 'Classroom Management', 'Assessment Methods', 'Differentiated Instruction', 'Teaching Challenge']},
          {'name': 'Curriculum Design', 'theme': 'mountain', 'icon': 'terrain',
           'levelTitles': ['Curriculum Theory', 'Learning Objectives', 'Content Development', 'Instructional Materials', 'Evaluation Methods', 'Curriculum Mastery']},
          {'name': 'Student Psychology', 'theme': 'castle', 'icon': 'castle',
           'levelTitles': ['Child Development', 'Learning Theories', 'Motivation & Engagement', 'Special Needs Education', 'Counseling Basics', 'Psychology Expert']},
        ];
      default:
        return [
          {'name': 'Foundational Concepts', 'theme': 'forest', 'icon': 'park',
           'levelTitles': ['Introduction', 'Basic Concepts', 'Core Principles', 'Practical Applications', 'Advanced Topics', 'Foundation Challenge']},
          {'name': 'Core Principles', 'theme': 'mountain', 'icon': 'terrain',
           'levelTitles': ['Core Theory', 'Methods', 'Analysis', 'Synthesis', 'Evaluation', 'Core Mastery']},
          {'name': 'Advanced Applications', 'theme': 'castle', 'icon': 'castle',
           'levelTitles': ['Advanced Theory', 'Complex Problems', 'Case Studies', 'Professional Skills', 'Integration', 'Expert Challenge']},
        ];
    }
  }

  Map<String, dynamic> _buildLevelData(String programId, int levelId, String title) {
    final isCompleted = _gameStateService.isLevelCompleted(programId, levelId);
    final isUnlocked = _gameStateService.isLevelUnlocked(programId, levelId);
    final stars = _gameStateService.getLevelStars(programId, levelId);
    final gems = _gameStateService.getLevelGems(programId, levelId);
    
    return {
      'id': levelId,
      'title': title,
      'isCompleted': isCompleted,
      'isLocked': !isUnlocked,
      'stars': stars,
      'gemsCollected': gems,
    };
  }

  List<Map<String, dynamic>> _buildInventory() {
    final powerUps = _gameStateService.powerUps;
    return [
      if ((powerUps['extra_time'] ?? 0) > 0)
        {'id': 1, 'name': 'Extra Time', 'icon': 'timer', 'quantity': powerUps['extra_time']},
      if ((powerUps['eliminate'] ?? 0) > 0)
        {'id': 2, 'name': 'Eliminate Wrong Answer', 'icon': 'highlight_off', 'quantity': powerUps['eliminate']},
      if ((powerUps['hint'] ?? 0) > 0)
        {'id': 3, 'name': 'Hint', 'icon': 'lightbulb', 'quantity': powerUps['hint']},
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _transformationController.dispose();
    _parallaxController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      final zoneWidth = 76.w + 2.w;
      _currentZoneIndex = (_scrollOffset / zoneWidth).floor().clamp(0, _worldZones.length - 1);
    });
  }

  void _handleLevelTap(Map<String, dynamic> levelData) {
    final isLocked = levelData['isLocked'] as bool;
    final levelId = levelData['id'] as int;
    
    if (isLocked) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete Level ${levelId - 1} first to unlock this level'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(
      context,
      AppRoutes.quizGameplay,
      arguments: {
        'programId': _currentProgram,
        'levelId': levelId,
        'levelTitle': levelData['title'],
      },
    );
  }

  void _handleInventoryTap() => _showInventoryDialog();
  void _handleStatsTap() => _showStatsDialog();
  
  void _handleMenuTap() {
    PauseMenuScreen.show(context, sourceScreen: 'game_world_map');
  }

  void _handleMiniMapTap() {
    _transformationController.value = Matrix4.identity();
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void _showInventoryDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(iconName: 'backpack', color: theme.colorScheme.primary, size: 24),
            SizedBox(width: 2.w),
            const Text('Inventory'),
          ],
        ),
        content: SizedBox(
          width: 80.w,
          child: _inventory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(iconName: 'inventory_2', color: theme.colorScheme.onSurfaceVariant, size: 48),
                      SizedBox(height: 2.h),
                      Text('No power-ups yet', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _inventory.length,
                  separatorBuilder: (_, __) => SizedBox(height: 1.h),
                  itemBuilder: (context, index) {
                    final item = _inventory[index];
                    return Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                            child: CustomIconWidget(iconName: item['icon'], color: theme.colorScheme.onPrimary, size: 24),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(child: Text(item['name'], style: theme.textTheme.titleSmall)),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(color: theme.colorScheme.tertiary, borderRadius: BorderRadius.circular(8)),
                            child: Text('x${item['quantity']}', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onTertiary, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showStatsDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(iconName: 'bar_chart', color: theme.colorScheme.primary, size: 24),
            SizedBox(width: 2.w),
            const Text('Player Stats'),
          ],
        ),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow(theme, icon: 'stars', label: 'Level', value: '${_playerStats['currentLevel']}'),
              SizedBox(height: 2.h),
              _buildStatRow(theme, icon: 'emoji_events', label: 'Total XP', value: '${_playerStats['totalXP']}'),
              SizedBox(height: 2.h),
              _buildStatRow(theme, icon: 'diamond', label: 'Gems Collected', value: '${_playerStats['gemsCollected']}'),
              SizedBox(height: 2.h),
              _buildStatRow(theme, icon: 'bolt', label: 'Power-ups', value: '${_playerStats['powerUpsOwned']}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildStatRow(ThemeData theme, {required String icon, required String label, required String value}) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(8)),
            child: CustomIconWidget(iconName: icon, color: theme.colorScheme.onPrimary, size: 24),
          ),
          SizedBox(width: 3.w),
          Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
        ],
      ),
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildParallaxBackground(theme),
          SafeArea(
            child: Column(
              children: [
                _buildTopAppBar(theme),
                Expanded(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.5,
                    maxScale: 2.0,
                    boundaryMargin: EdgeInsets.all(20.w),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _worldZones.map((zone) {
                            final index = _worldZones.indexOf(zone);
                            final isUnlocked = index == 0 ||
                                (_worldZones[index - 1]['levels'] as List).every((level) => level['isCompleted'] as bool);
                            return WorldMapZoneWidget(
                              zoneData: zone,
                              onLevelTap: (levelData) => _handleLevelTap(levelData),
                              isUnlocked: isUnlocked,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                BottomToolbarWidget(
                  playerStats: _playerStats,
                  inventory: _inventory,
                  onInventoryTap: _handleInventoryTap,
                  onStatsTap: _handleStatsTap,
                  onMenuTap: _handleMenuTap,
                ),
              ],
            ),
          ),
          Positioned(
            left: 20.w,
            top: 20.h,
            child: CharacterAvatarWidget(
              characterData: _characterData,
              positionX: 0,
              positionY: 0,
              isMoving: _isCharacterMoving,
            ),
          ),
          Positioned(
            top: 12.h,
            right: 4.w,
            child: MiniMapWidget(
              zones: _worldZones,
              currentZoneIndex: _currentZoneIndex,
              onTap: _handleMiniMapTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParallaxBackground(ThemeData theme) {
    return AnimatedBuilder(
      animation: _parallaxController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF87CEEB).withValues(alpha: 0.3), theme.scaffoldBackgroundColor],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -100 + (_parallaxController.value * 200) - (_scrollOffset * 0.1),
              top: 10.h,
              child: Opacity(opacity: 0.3, child: CustomIconWidget(iconName: 'cloud', color: Colors.white, size: 80)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopAppBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(iconName: 'arrow_back', color: theme.colorScheme.onSurface, size: 24),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('World Map', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                Text(_programName, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.primary, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(iconName: 'stars', color: theme.colorScheme.primary, size: 20),
                SizedBox(width: 1.w),
                Text('${_playerStats['totalXP']} XP',
                    style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
