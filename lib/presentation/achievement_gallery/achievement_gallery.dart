import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/achievement_category_section.dart';
import './widgets/achievement_detail_modal.dart';
import './widgets/achievement_header_stats.dart';

class AchievementGallery extends StatefulWidget {
  const AchievementGallery({super.key});

  @override
  State<AchievementGallery> createState() => _AchievementGalleryState();
}

class _AchievementGalleryState extends State<AchievementGallery>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 2;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // Mock achievement data
  final List<Map<String, dynamic>> _achievements = [
    {
      "id": 1,
      "category": "Academic Excellence",
      "title": "First Steps",
      "description": "Complete your first quiz successfully",
      "icon": "school",
      "unlocked": true,
      "unlockDate": "2025-12-15",
      "rarity": 95.5,
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_16647e395-1765368744119.png",
      "semanticLabel":
          "Open textbook with colorful sticky notes on wooden desk with coffee cup and glasses",
    },
    {
      "id": 2,
      "category": "Academic Excellence",
      "title": "Knowledge Seeker",
      "description": "Complete 10 quizzes across different programs",
      "icon": "menu_book",
      "unlocked": true,
      "unlockDate": "2025-12-20",
      "rarity": 78.3,
      "image": "https://images.unsplash.com/photo-1592503286362-34e28f5a5ff7",
      "semanticLabel":
          "Stack of colorful books with reading glasses on top against white background",
    },
    {
      "id": 3,
      "category": "Academic Excellence",
      "title": "Master Scholar",
      "description": "Complete all levels in one academic program",
      "icon": "workspace_premium",
      "unlocked": false,
      "unlockDate": null,
      "rarity": 45.2,
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_16558c44f-1766953755377.png",
      "semanticLabel":
          "Graduation cap and diploma scroll with red ribbon on wooden surface",
    },
    {
      "id": 4,
      "category": "Speed Master",
      "title": "Quick Thinker",
      "description": "Complete a quiz in under 2 minutes",
      "icon": "flash_on",
      "unlocked": true,
      "unlockDate": "2025-12-18",
      "rarity": 65.8,
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1e56f4bc4-1766745239097.png",
      "semanticLabel":
          "Yellow lightning bolt icon on dark blue background with glowing effect",
    },
    {
      "id": 5,
      "category": "Speed Master",
      "title": "Lightning Fast",
      "description": "Complete 5 quizzes in under 90 seconds each",
      "icon": "bolt",
      "unlocked": false,
      "unlockDate": null,
      "rarity": 32.1,
      "image": "https://images.unsplash.com/photo-1641567926412-7a6158b8e81f",
      "semanticLabel":
          "Stopwatch showing fast time with motion blur effect on dark background",
    },
    {
      "id": 6,
      "category": "Perfect Scores",
      "title": "Perfectionist",
      "description": "Score 100% on any quiz",
      "icon": "stars",
      "unlocked": true,
      "unlockDate": "2025-12-22",
      "rarity": 58.7,
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_13e17ad8a-1766559729302.png",
      "semanticLabel":
          "Gold star trophy with sparkles on blue gradient background",
    },
    {
      "id": 7,
      "category": "Perfect Scores",
      "title": "Flawless Victory",
      "description": "Score 100% on 10 consecutive quizzes",
      "icon": "emoji_events",
      "unlocked": false,
      "unlockDate": null,
      "rarity": 15.4,
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_155fde3e3-1767017434226.png",
      "semanticLabel":
          "Golden trophy cup with laurel wreath on marble pedestal",
    },
    {
      "id": 8,
      "category": "Special Events",
      "title": "Early Bird",
      "description": "Complete a quiz before 8 AM",
      "icon": "wb_sunny",
      "unlocked": true,
      "unlockDate": "2025-12-16",
      "rarity": 42.9,
      "image": "https://images.unsplash.com/photo-1660387673481-d08e2792c038",
      "semanticLabel":
          "Sunrise over mountains with orange and pink sky and silhouetted peaks",
    },
    {
      "id": 9,
      "category": "Special Events",
      "title": "Weekend Warrior",
      "description": "Complete 5 quizzes on weekends",
      "icon": "celebration",
      "unlocked": false,
      "unlockDate": null,
      "rarity": 51.3,
      "image": "https://images.unsplash.com/photo-1578146003982-3e89cc2c606b",
      "semanticLabel":
          "Colorful confetti and party streamers falling against white background",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    if (index == _currentBottomNavIndex) return;

    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.gameWorldMap);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.progressAnalytics);
        break;
      case 2:
        // Current screen (Achievement Gallery)
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.characterCustomization);
        break;
    }
  }

  List<Map<String, dynamic>> get _filteredAchievements {
    if (_searchQuery.isEmpty) {
      return _achievements;
    }
    return _achievements
        .where(
          (achievement) =>
              (achievement["title"] as String).toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (achievement["category"] as String).toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedAchievements {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var achievement in _filteredAchievements) {
      final category = achievement["category"] as String;
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(achievement);
    }
    return grouped;
  }

  int get _totalAchievements => _achievements.length;
  int get _unlockedCount =>
      _achievements.where((a) => a["unlocked"] == true).length;
  double get _completionPercentage =>
      (_unlockedCount / _totalAchievements) * 100;

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Achievements updated'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAchievementDetail(Map<String, dynamic> achievement) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AchievementDetailModal(achievement: achievement),
    );
  }

  void _showAchievementGuide() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Achievement Guide', style: theme.textTheme.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Unlock achievements by:',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildGuideItem(
                  theme,
                  'Academic Excellence',
                  'Complete quizzes and master programs',
                ),
                _buildGuideItem(
                  theme,
                  'Speed Master',
                  'Finish quizzes quickly',
                ),
                _buildGuideItem(theme, 'Perfect Scores', 'Get 100% on quizzes'),
                _buildGuideItem(
                  theme,
                  'Special Events',
                  'Complete challenges at specific times',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGuideItem(ThemeData theme, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _isSearching
          ? AppBar(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                tooltip: 'Back',
              ),
              title: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search achievements...',
                  border: InputBorder.none,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                style: theme.textTheme.bodyLarge,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              actions: [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    tooltip: 'Clear',
                  ),
              ],
            )
          : CustomAppBar(
              title: 'Achievements',
              variant: CustomAppBarVariant.standard,
              actions: [
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  tooltip: 'Search',
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'help_outline',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: _showAchievementGuide,
                  tooltip: 'Achievement Guide',
                ),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AchievementHeaderStats(
                totalAchievements: _totalAchievements,
                unlockedCount: _unlockedCount,
                completionPercentage: _completionPercentage,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  indicatorColor: theme.colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Achievements'),
                    Tab(text: 'Locked'),
                  ],
                ),
              ),
            ),
            _filteredAchievements.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'search_off',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No achievements found',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverToBoxAdapter(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAchievementsList(true),
                        _buildAchievementsList(false),
                      ],
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAchievementGuide,
        tooltip: 'Achievement Guide',
        child: CustomIconWidget(
          iconName: 'info_outline',
          color: theme.colorScheme.onSecondary,
          size: 24,
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildAchievementsList(bool showUnlocked) {
    final categories = _groupedAchievements.keys.toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final achievements = _groupedAchievements[category]!
              .where((a) => a["unlocked"] == showUnlocked)
              .toList();

          if (achievements.isEmpty) {
            return const SizedBox.shrink();
          }

          return AchievementCategorySection(
            category: category,
            achievements: achievements,
            onAchievementTap: _showAchievementDetail,
          );
        },
      ),
    );
  }
}
