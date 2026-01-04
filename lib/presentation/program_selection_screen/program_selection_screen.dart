import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/game_state_service.dart';
import './widgets/program_card_widget.dart';
import './widgets/program_detail_modal.dart';

/// Program Selection Screen - Academic adventure path chooser
///
/// Features:
/// - Grid-based program card layout (2 columns)
/// - Program-specific themed artwork
/// - Difficulty indicators and progress tracking
/// - Search and filter functionality
/// - Pull-to-refresh for content updates
/// - Recommended programs bottom sheet
/// - Achievement badges for completed programs
class ProgramSelectionScreen extends StatefulWidget {
  const ProgramSelectionScreen({super.key});

  @override
  State<ProgramSelectionScreen> createState() => _ProgramSelectionScreenState();
}

class _ProgramSelectionScreenState extends State<ProgramSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _filteredPrograms = [];
  bool _isRefreshing = false;
  String _searchQuery = '';

  // Mock program data with themed artwork and progress
  final List<Map<String, dynamic>> _programs = [
    {
      "id": "bsit",
      "abbreviation": "BSIT",
      "fullName": "Bachelor of Science in Information Technology",
      "description":
          "Master the digital realm through programming, networks, and system administration. Navigate through code matrices and digital landscapes to become an IT champion.",
      "difficulty": 4,
      "estimatedTime": "45-60 hours",
      "levelCount": 16,
      "progress": 0.35,
      "isStarted": true,
      "isCompleted": false,
      "themeColor": 0xFF4A90E2,
      "imageUrl":
          "https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80",
      "semanticLabel":
          "Digital technology background with glowing blue circuit board patterns and binary code streams",
      "zones": [
        "Programming Fundamentals",
        "Network Architecture",
        "Database Systems",
      ],
      "achievements": ["Code Warrior", "Network Navigator"],
    },
    {
      "id": "bsba",
      "abbreviation": "BSBA",
      "fullName": "Bachelor of Science in Business Administration",
      "description":
          "Conquer the business world through strategic thinking, management skills, and entrepreneurial spirit. Build your empire across urban landscapes.",
      "difficulty": 3,
      "estimatedTime": "50-65 hours",
      "levelCount": 16,
      "progress": 0.0,
      "isStarted": false,
      "isCompleted": false,
      "themeColor": 0xFF7B68EE,
      "imageUrl":
          "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80",
      "semanticLabel":
          "Modern glass skyscraper cityscape with reflective blue windows against clear sky",
      "zones": [
        "Business Foundations",
        "Marketing Strategy",
        "Financial Management",
      ],
      "achievements": [],
    },
    {
      "id": "bsed",
      "abbreviation": "BSED",
      "fullName": "Bachelor of Secondary Education",
      "description":
          "Shape young minds and inspire the next generation. Journey through pedagogical landscapes and educational methodologies.",
      "difficulty": 3,
      "estimatedTime": "55-70 hours",
      "levelCount": 16,
      "progress": 0.0,
      "isStarted": false,
      "isCompleted": false,
      "themeColor": 0xFF5CB85C,
      "imageUrl":
          "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800&q=80",
      "semanticLabel":
          "Bright classroom interior with wooden desks, green chalkboard, and large windows with natural light",
      "zones": ["Teaching Methods", "Curriculum Design", "Student Psychology"],
      "achievements": [],
    },
    {
      "id": "beed",
      "abbreviation": "BEED",
      "fullName": "Bachelor of Elementary Education",
      "description":
          "Nurture young learners and build strong educational foundations. Explore creative teaching methods and child development.",
      "difficulty": 2,
      "estimatedTime": "50-65 hours",
      "levelCount": 16,
      "progress": 0.0,
      "isStarted": false,
      "isCompleted": false,
      "themeColor": 0xFFF0AD4E,
      "imageUrl":
          "https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=800&q=80",
      "semanticLabel":
          "Colorful elementary classroom with small chairs, educational posters, and bright learning materials",
      "zones": [
        "Early Childhood Education",
        "Learning Activities",
        "Child Development",
      ],
      "achievements": [],
    },
    {
      "id": "bsa",
      "abbreviation": "BSA",
      "fullName": "Bachelor of Science in Accountancy",
      "description":
          "Master the language of business through financial analysis and accounting principles. Navigate ledgers and balance sheets to financial mastery.",
      "difficulty": 5,
      "estimatedTime": "60-75 hours",
      "levelCount": 16,
      "progress": 0.0,
      "isStarted": false,
      "isCompleted": false,
      "themeColor": 0xFFE67E22,
      "imageUrl":
          "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80",
      "semanticLabel":
          "Professional accounting workspace with calculator, financial documents, and spreadsheets on wooden desk",
      "zones": ["Financial Accounting", "Auditing", "Tax Management"],
      "achievements": [],
    },
    {
      "id": "bshm",
      "abbreviation": "BSHM",
      "fullName": "Bachelor of Science in Hospitality Management",
      "description":
          "Create exceptional guest experiences and master the art of hospitality. Journey through hotels, restaurants, and event management.",
      "difficulty": 3,
      "estimatedTime": "45-60 hours",
      "levelCount": 16,
      "progress": 0.0,
      "isStarted": false,
      "isCompleted": false,
      "themeColor": 0xFFD9534F,
      "imageUrl":
          "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80",
      "semanticLabel":
          "Luxury hotel lobby with elegant chandelier, marble floors, and modern reception desk",
      "zones": ["Hotel Operations", "Food Service", "Event Management"],
      "achievements": [],
    },
    {
      "id": "bscs",
      "abbreviation": "BSCS",
      "fullName": "Bachelor of Science in Computer Science",
      "description":
          "Dive deep into algorithms, data structures, and software engineering. Explore the theoretical foundations of computing.",
      "difficulty": 5,
      "estimatedTime": "60-80 hours",
      "levelCount": 16,
      "progress": 0.65,
      "isStarted": true,
      "isCompleted": false,
      "themeColor": 0xFF4A90E2,
      "imageUrl":
          "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80",
      "semanticLabel":
          "Computer screen displaying colorful programming code with syntax highlighting in dark theme",
      "zones": [
        "Algorithm Design",
        "Software Engineering",
        "Artificial Intelligence",
      ],
      "achievements": ["Algorithm Master", "Code Architect"],
    },
    {
      "id": "bscpe",
      "abbreviation": "BSCpE",
      "fullName": "Bachelor of Science in Computer Engineering",
      "description":
          "Bridge hardware and software through embedded systems and computer architecture. Master the physical and digital realms.",
      "difficulty": 5,
      "estimatedTime": "65-80 hours",
      "levelCount": 16,
      "progress": 0.0,
      "isStarted": false,
      "isCompleted": false,
      "themeColor": 0xFF7B68EE,
      "imageUrl":
          "https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80",
      "semanticLabel":
          "Close-up of electronic circuit board with microchips, resistors, and glowing LED components",
      "zones": [
        "Digital Systems",
        "Embedded Programming",
        "Computer Architecture",
      ],
      "achievements": [],
    },
    {
      "id": "ahm",
      "abbreviation": "AHM",
      "fullName": "Associate in Hospitality Management",
      "description":
          "Fast-track your hospitality career with essential management skills. Perfect for aspiring hotel and restaurant professionals.",
      "difficulty": 2,
      "estimatedTime": "30-40 hours",
      "levelCount": 12,
      "progress": 0.0,
      "isStarted": false,
      "isCompleted": false,
      "themeColor": 0xFFF0AD4E,
      "imageUrl":
          "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80",
      "semanticLabel":
          "Restaurant interior with elegant table settings, wine glasses, and ambient lighting",
      "zones": ["Guest Services", "Food & Beverage", "Front Office"],
      "achievements": [],
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredPrograms = List.from(_programs);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredPrograms = _programs.where((program) {
        final name = (program['fullName'] as String).toLowerCase();
        final abbr = (program['abbreviation'] as String).toLowerCase();
        final difficulty = program['difficulty'].toString();
        return name.contains(_searchQuery) ||
            abbr.contains(_searchQuery) ||
            difficulty.contains(_searchQuery);
      }).toList();
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);

    // Simulate content update and achievement check
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isRefreshing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Programs updated successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showProgramDetails(Map<String, dynamic> program) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProgramDetailModal(program: program),
    );
  }

  void _showRecommendations() {
    final theme = Theme.of(context);

    // Filter programs based on started/completed status
    final startedPrograms = _programs
        .where((p) => p['isStarted'] == true)
        .toList();
    final completedPrograms = _programs
        .where((p) => p['isCompleted'] == true)
        .toList();

    // Simple recommendation logic
    List<Map<String, dynamic>> recommendations = [];

    if (startedPrograms.isNotEmpty) {
      // Recommend similar difficulty programs
      final avgDifficulty =
          startedPrograms.fold<int>(
            0,
            (sum, p) => sum + (p['difficulty'] as int),
          ) ~/
          startedPrograms.length;

      recommendations = _programs
          .where((p) {
            return !p['isStarted'] &&
                ((p['difficulty'] as int) - avgDifficulty).abs() <= 1;
          })
          .take(3)
          .toList();
    } else {
      // Recommend beginner-friendly programs
      recommendations = _programs
          .where((p) => (p['difficulty'] as int) <= 3)
          .take(3)
          .toList();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 1.h),
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'auto_awesome',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Recommended for You',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: theme.colorScheme.outline),

            // Recommendations list
            Expanded(
              child: recommendations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'school',
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                            size: 48,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Start a program to get recommendations',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(4.w),
                      itemCount: recommendations.length,
                      itemBuilder: (context, index) {
                        final program = recommendations[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 2.h),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(3.w),
                            leading: Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: Color(
                                  program['themeColor'] as int,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  program['abbreviation'] as String,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Color(program['themeColor'] as int),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              program['fullName'] as String,
                              style: theme.textTheme.titleSmall,
                            ),
                            subtitle: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'star',
                                  color: theme.colorScheme.tertiary,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Difficulty: ${program['difficulty']}/5',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            trailing: CustomIconWidget(
                              iconName: 'arrow_forward',
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _showProgramDetails(program);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleProgramAction(Map<String, dynamic> program, String action) async {
    final theme = Theme.of(context);
    final gameStateService = GameStateService();
    
    if (!gameStateService.isInitialized) {
      await gameStateService.initialize();
    }

    switch (action) {
      case 'start':
        // Save selected program to game state
        await gameStateService.setCurrentProgram(program['id'] as String);
        // Navigate with program ID
        if (mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.gameWorldMap,
            arguments: {'programId': program['id']},
          );
        }
        break;
      case 'view_progress':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Progress: ${(program['progress'] * 100).toInt()}% complete',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        break;
      case 'reset':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Progress'),
            content: Text(
              'Are you sure you want to reset your progress in ${program['abbreviation']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    program['progress'] = 0.0;
                    program['isStarted'] = false;
                    (program['achievements'] as List).clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Progress reset successfully'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'map',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Main Menu',
        ),
        title: Text(
          'Choose Your Path',
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () => Navigator.pushNamed(context, '/pause-menu-screen'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.all(4.w),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search programs or difficulty...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        size: 20,
                      ),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Programs grid
              Expanded(
                child: _filteredPrograms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'search_off',
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                              size: 48,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No programs found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Try adjusting your search',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 2.h,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 2.w,
                          mainAxisSpacing: 2.h,
                          childAspectRatio: 0.66,
                        ),
                        itemCount: _filteredPrograms.length,
                        itemBuilder: (context, index) {
                          final program = _filteredPrograms[index];
                          return ProgramCardWidget(
                            program: program,
                            onTap: () => _showProgramDetails(program),
                            onLongPress: () => _showQuickActions(program),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRecommendations,
        icon: CustomIconWidget(
          iconName: 'auto_awesome',
          color: theme.colorScheme.onTertiary,
          size: 24,
        ),
        label: const Text('Recommended'),
      ),
    );
  }

  void _showQuickActions(Map<String, dynamic> program) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 1.h),
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Program header
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: Color(
                          program['themeColor'] as int,
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          program['abbreviation'] as String,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Color(program['themeColor'] as int),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        program['fullName'] as String,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: theme.colorScheme.outline),

              // Quick actions
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'play_arrow',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: const Text('Start Program'),
                onTap: () {
                  Navigator.pop(context);
                  _handleProgramAction(program, 'start');
                },
              ),

              if (program['isStarted'] == true)
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'analytics',
                    color: theme.colorScheme.secondary,
                    size: 24,
                  ),
                  title: const Text('View Progress'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleProgramAction(program, 'view_progress');
                  },
                ),

              if (program['isStarted'] == true)
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'refresh',
                    color: theme.colorScheme.error,
                    size: 24,
                  ),
                  title: const Text('Reset Progress'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleProgramAction(program, 'reset');
                  },
                ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
