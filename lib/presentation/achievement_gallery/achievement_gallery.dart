import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/game_state_service.dart';

class AchievementGallery extends StatefulWidget {
  const AchievementGallery({super.key});

  @override
  State<AchievementGallery> createState() => _AchievementGalleryState();
}

class _AchievementGalleryState extends State<AchievementGallery>
    with SingleTickerProviderStateMixin {
  int _currentBottomNavIndex = 2;
  late TabController _tabController;
  final GameStateService _gameStateService = GameStateService();

  List<Map<String, dynamic>> _programAchievements = [];
  List<Map<String, dynamic>> _specialAchievements = [];
  Map<String, dynamic> _playerStats = {};

  // Custom Color Palette for Colorful Theme
  static const Color kPrimaryPurple = Color(0xFF6C63FF);
  static const Color kPrimaryOrange = Color(0xFFFF6584);
  static const Color kPrimaryBlue = Color(0xFF4FC3F7);
  static const Color kBgColor = Color(0xFFFAFAFA); // Light Grey/White
  static const Color kCardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!_gameStateService.isInitialized) {
      await _gameStateService.initialize();
    }

    // Load player stats
    _playerStats = {
      'totalXP': _gameStateService.totalXP,
      'totalGems': _gameStateService.totalGems,
      'level': _gameStateService.currentLevel,
    };

    final unlockedIds = _gameStateService.unlockedAchievementIds;
    final newProgramAchievements = <Map<String, dynamic>>[];
    final newSpecialAchievements = <Map<String, dynamic>>[];

    // 1. Program Achievements (Novice/Expert/Master)
    final programs = [
      {'id': 'bsit', 'name': 'BSIT', 'color': Colors.blue},
      {'id': 'bsba', 'name': 'BSBA', 'color': Colors.amber},
      {'id': 'bsed', 'name': 'BSED', 'color': Colors.green},
      {'id': 'beed', 'name': 'BEED', 'color': Colors.teal},
      {'id': 'bsa', 'name': 'BSA', 'color': Colors.indigo},
      {'id': 'bshm', 'name': 'BSHM', 'color': Colors.orange},
      {'id': 'bscs', 'name': 'BSCS', 'color': Colors.deepPurple},
      {'id': 'bscpe', 'name': 'BSCpE', 'color': Colors.cyan},
      {'id': 'ahm', 'name': 'AHM', 'color': Colors.pink},
    ];

    final programPrefixes = {
      'bsit': 100,
      'bsba': 200,
      'bsed': 300,
      'beed': 400,
      'bsa': 500,
      'bshm': 600,
      'bscs': 700,
      'bscpe': 800,
      'ahm': 900,
    };

    for (var program in programs) {
      final pid = program['id'] as String;
      final pname = program['name'] as String;
      // final pColor = program['color'] as Color; // Unused
      final prefix = programPrefixes[pid] ?? 1000;

      // Novice (Bronze)
      newProgramAchievements.add({
        "id": prefix + 1,
        "category": pname,
        "title": "Novice",
        "icon": "verified",
        "unlocked": unlockedIds.contains(prefix + 1),
        "tier": "Bronze",
        "color": const Color(0xFFCD7F32), // Bronze
      });

      // Expert (Silver)
      newProgramAchievements.add({
        "id": prefix + 2,
        "category": pname,
        "title": "Expert",
        "icon": "workspace_premium",
        "unlocked": unlockedIds.contains(prefix + 2),
        "tier": "Silver",
        "color": const Color(0xFFC0C0C0), // Silver
      });

      // Master (Gold)
      newProgramAchievements.add({
        "id": prefix + 3,
        "category": pname,
        "title": "Master",
        "icon": "military_tech",
        "unlocked": unlockedIds.contains(prefix + 3),
        "tier": "Gold",
        "color": const Color(0xFFFFD700), // Gold
      });
    }

    // 2. Special Achievements (Level-based)
    // Perfect Scholar (88881)
    newSpecialAchievements.add({
      "id": 88881,
      "title": "Perfect Scholar",
      "description": "90% Accuracy in a Level",
      "icon": "school",
      "unlocked": unlockedIds.contains(88881),
      "startColor": const Color(0xFF9C27B0),
      "endColor": const Color(0xFFE040FB),
    });

    // Speed Demon (88882)
    newSpecialAchievements.add({
      "id": 88882,
      "title": "Speed Demon",
      "description": "< 3 Mins Completion",
      "icon": "bolt",
      "unlocked": unlockedIds.contains(88882),
      "startColor": const Color(0xFFFF9800),
      "endColor": const Color(0xFFFFC107),
    });

    // Star Collector (88883)
    newSpecialAchievements.add({
      "id": 88883,
      "title": "Star Collector",
      "description": "Earned 3 Stars",
      "icon": "star",
      "unlocked": unlockedIds.contains(88883),
      "startColor": const Color(0xFFFFD700),
      "endColor": const Color(0xFFFFE082),
    });

    if (mounted) {
      setState(() {
        _programAchievements = newProgramAchievements;
        _specialAchievements = newSpecialAchievements;
      });
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == _currentBottomNavIndex) return;
    setState(() => _currentBottomNavIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.gameWorldMap);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.progressAnalytics);
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.characterCustomization,
        );
        break;
    }
  }

  Map<String, List<Map<String, dynamic>>> get _groupedProgramAchievements {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var achievement in _programAchievements) {
      final category = achievement["category"] as String;
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(achievement);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Styled AppBar / Header
            Container(
              padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 0),
              color: kBgColor,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Achievements',
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: kPrimaryPurple,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              "${_gameStateService.unlockedAchievementIds.length} Unlocked",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: kPrimaryPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Level",
                          "${_playerStats['level']}",
                          Colors.blue,
                          "trending_up",
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildStatCard(
                          "Gems",
                          "${_playerStats['totalGems']}",
                          kPrimaryOrange,
                          "diamond",
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildStatCard(
                          "XP",
                          "${_playerStats['totalXP']}",
                          Colors.amber,
                          "bolt",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  // Tab Bar
                  Container(
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: Colors.black87,
                      unselectedLabelColor: Colors.grey.shade600,
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                      tabs: const [
                        Tab(text: "Programs"),
                        Tab(text: "Special"),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: BouncingScrollPhysics(),
                children: [
                  // Program Achievements
                  _buildProgramTab(),
                  // Special Achievements
                  _buildSpecialTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, String icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          CustomIconWidget(iconName: icon, color: color, size: 24),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 8.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramTab() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      physics: ClampingScrollPhysics(),
      itemCount: _groupedProgramAchievements.length,
      itemBuilder: (context, index) {
        final category = _groupedProgramAchievements.keys.elementAt(index);
        final achievements = _groupedProgramAchievements[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 1.5.h, top: 1.h),
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Row(
              children: achievements.map((item) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: _buildProgramBadge(item),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 2.h),
          ],
        );
      },
    );
  }

  Widget _buildProgramBadge(Map<String, dynamic> item) {
    final unlocked = item['unlocked'] as bool;
    final color = item['color'] as Color;

    return Container(
      height: 14.h,
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : [],
        border: Border.all(
          color: unlocked ? color.withValues(alpha: 0.3) : Colors.grey.shade200,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? color.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
            ),
            child: Icon(
              unlocked ? _getIconData(item['icon']) : Icons.lock,
              color: unlocked ? color : Colors.grey.shade400,
              size: 24,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            item['title'],
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: unlocked ? Colors.black87 : Colors.grey.shade400,
            ),
          ),
          Text(
            unlocked ? item['tier'] : "Locked",
            style: GoogleFonts.poppins(
              fontSize: 7.sp,
              color: unlocked ? color : Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialTab() {
    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      physics: BouncingScrollPhysics(),
      itemCount: _specialAchievements.length,
      separatorBuilder: (_, __) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final item = _specialAchievements[index];
        final unlocked = item['unlocked'] as bool;
        final startColor = item['startColor'] as Color;
        final endColor = item['endColor'] as Color;

        return Opacity(
          opacity: unlocked ? 1.0 : 0.6,
          child: Container(
            height: 10.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: unlocked
                    ? [startColor, endColor]
                    : [Colors.grey.shade300, Colors.grey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: startColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: item['icon'],
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        unlocked
                            ? item['description']
                            : "Keep playing to unlock!",
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (unlocked)
                  Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'verified':
        return Icons.verified;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'military_tech':
        return Icons.military_tech;
      default:
        return Icons.star;
    }
  }
}
