import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/overall_performance_widget.dart';
import './widgets/program_breakdown_widget.dart';
import './widgets/trends_analysis_widget.dart';

/// Progress Analytics Screen
///
/// Provides comprehensive learning insights through mobile-optimized data visualization
/// Features:
/// - Tab bar navigation with Progress tab active
/// - Program selector dropdown and date range picker
/// - Expandable sections: Overall Performance, Program Breakdown, Trends Analysis
/// - Interactive charts with touch-responsive graphs
/// - Pinch-to-zoom for detailed chart exploration
/// - Summary cards with key metrics
/// - Swipe gestures for chart navigation
/// - Program comparison with side-by-side performance
/// - Export functionality for PDF reports
/// - Long-press tooltips for data points
/// - Bottom sheet filtering options
/// - Pull-to-refresh for analytics updates
class ProgressAnalytics extends StatefulWidget {
  const ProgressAnalytics({super.key});

  @override
  State<ProgressAnalytics> createState() => _ProgressAnalyticsState();
}

class _ProgressAnalyticsState extends State<ProgressAnalytics>
    with SingleTickerProviderStateMixin {
  int _currentBottomNavIndex = 1; // Progress tab active
  late TabController _tabController;
  String _selectedProgram = 'All Programs';
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;

  final List<String> _programs = [
    'All Programs',
    'BSIT',
    'BSBA',
    'BSED',
    'BEED',
    'BA',
    'BSHM',
    'BSCS',
    'BSCpE',
    'AHM',
  ];

  // Mock analytics data
  final Map<String, dynamic> _analyticsData = {
    "totalStudyTime": "47h 32m",
    "averageAccuracy": 87.5,
    "strongestSubject": "Programming Fundamentals",
    "weakestSubject": "Database Management",
    "improvementTrend": "+12%",
    "totalQuizzes": 156,
    "completionRate": 94.2,
    "knowledgeGems": 1247,
    "currentStreak": 12,
    "lastUpdated": "2026-01-03 11:15:22",
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDateRange();
  }

  void _initializeDateRange() {
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month - 1, now.day),
      end: now,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshAnalytics() async {
    setState(() => _isLoading = true);
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedProgram: _selectedProgram,
        selectedDateRange: _selectedDateRange,
        programs: _programs,
        onApplyFilters: (program, dateRange) {
          setState(() {
            _selectedProgram = program;
            _selectedDateRange = dateRange;
          });
          _refreshAnalytics();
        },
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final theme = Theme.of(context);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() => _selectedDateRange = picked);
      _refreshAnalytics();
    }
  }

  void _exportReport() {
    // Export functionality - would generate PDF report
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Generating PDF report...'),
        action: SnackBarAction(label: 'View', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Progress Analytics',
        variant: CustomAppBarVariant.standard,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAnalytics,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildFilterHeader(theme),
                _buildTabBar(theme),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState(theme)
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: OverallPerformanceWidget(
                                analyticsData: _analyticsData,
                                selectedProgram: _selectedProgram,
                                dateRange: _selectedDateRange!,
                              ),
                            ),
                            SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ProgramBreakdownWidget(
                                selectedProgram: _selectedProgram,
                                dateRange: _selectedDateRange!,
                              ),
                            ),
                            SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: TrendsAnalysisWidget(
                                selectedProgram: _selectedProgram,
                                dateRange: _selectedDateRange!,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportReport,
        icon: CustomIconWidget(
          iconName: 'download',
          color: theme.colorScheme.onSecondary,
          size: 24,
        ),
        label: Text(
          'Export PDF',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          if (index == _currentBottomNavIndex) return;

          setState(() => _currentBottomNavIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.gameWorldMap);
              break;
            case 1:
              // Already on Progress Analytics
              break;
            case 2:
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.achievementGallery,
              );
              break;
            case 3:
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.characterCustomization,
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildFilterHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildProgramSelector(theme)),
              SizedBox(width: 3.w),
              _buildDateRangeButton(theme),
            ],
          ),
          SizedBox(height: 1.h),
          _buildLastUpdatedText(theme),
        ],
      ),
    );
  }

  Widget _buildProgramSelector(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProgram,
          isExpanded: true,
          icon: CustomIconWidget(
            iconName: 'arrow_drop_down',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          style: theme.textTheme.bodyMedium,
          items: _programs.map((String program) {
            return DropdownMenuItem<String>(
              value: program,
              child: Text(program),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedProgram = newValue);
              _refreshAnalytics();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDateRangeButton(ThemeData theme) {
    final startDate = _selectedDateRange!.start;
    final endDate = _selectedDateRange!.end;
    final dateText =
        '${startDate.month}/${startDate.day} - ${endDate.month}/${endDate.day}';

    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'calendar_today',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              dateText,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdatedText(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: 'update',
          color: theme.colorScheme.onSurfaceVariant,
          size: 14,
        ),
        SizedBox(width: 1.w),
        Text(
          'Last updated: ${_analyticsData["lastUpdated"]}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Programs'),
          Tab(text: 'Trends'),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          SizedBox(height: 2.h),
          Text(
            'Loading analytics...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
