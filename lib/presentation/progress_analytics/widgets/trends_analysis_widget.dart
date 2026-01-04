import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Trends Analysis Widget
///
/// Displays learning trends and patterns including:
/// - Performance trends over time
/// - Subject difficulty analysis
/// - Learning velocity metrics
/// - Predictive insights
class TrendsAnalysisWidget extends StatefulWidget {
  final String selectedProgram;
  final DateTimeRange dateRange;

  const TrendsAnalysisWidget({
    super.key,
    required this.selectedProgram,
    required this.dateRange,
  });

  @override
  State<TrendsAnalysisWidget> createState() => _TrendsAnalysisWidgetState();
}

class _TrendsAnalysisWidgetState extends State<TrendsAnalysisWidget> {
  int _selectedChartIndex = 0;

  final List<String> _chartTypes = [
    'Accuracy Trend',
    'Study Time',
    'Quiz Completion',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartSelector(theme),
          SizedBox(height: 3.h),
          _buildTrendChart(theme),
          SizedBox(height: 3.h),
          _buildInsightsSection(theme),
          SizedBox(height: 3.h),
          _buildDifficultyAnalysis(theme),
          SizedBox(height: 3.h),
          _buildLearningVelocity(theme),
        ],
      ),
    );
  }

  Widget _buildChartSelector(ThemeData theme) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          _chartTypes.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedChartIndex = index),
              child: Container(
                margin: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: _selectedChartIndex == index
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  _chartTypes[index],
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _selectedChartIndex == index
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: _selectedChartIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendChart(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _chartTypes[_selectedChartIndex],
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 220,
            child: Semantics(
              label: '${_chartTypes[_selectedChartIndex]} Line Chart',
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _selectedChartIndex == 0 ? 20 : 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outlineVariant,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _selectedChartIndex == 0
                                ? '${value.toInt()}%'
                                : '${value.toInt()}h',
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const months = ['Dec', 'Jan', 'Feb', 'Mar'];
                          if (value.toInt() >= 0 &&
                              value.toInt() < months.length) {
                            return Text(
                              months[value.toInt()],
                              style: theme.textTheme.labelSmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 3,
                  minY: 0,
                  maxY: _selectedChartIndex == 0 ? 100 : 25,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getChartData(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getChartData() {
    switch (_selectedChartIndex) {
      case 0: // Accuracy
        return const [
          FlSpot(0, 75),
          FlSpot(1, 82),
          FlSpot(2, 85),
          FlSpot(3, 87.5),
        ];
      case 1: // Study Time
        return const [
          FlSpot(0, 8),
          FlSpot(1, 12),
          FlSpot(2, 15),
          FlSpot(3, 18),
        ];
      case 2: // Quiz Completion
        return const [
          FlSpot(0, 10),
          FlSpot(1, 15),
          FlSpot(2, 18),
          FlSpot(3, 22),
        ];
      default:
        return const [];
    }
  }

  Widget _buildInsightsSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text('Key Insights', style: theme.textTheme.titleMedium),
            ],
          ),
          SizedBox(height: 2.h),
          _buildInsightItem(
            theme,
            'Your accuracy has improved by 12% over the last month',
            'trending_up',
            const Color(0xFF4CAF50),
          ),
          SizedBox(height: 1.h),
          _buildInsightItem(
            theme,
            'You\'re most productive during morning study sessions',
            'wb_sunny',
            const Color(0xFFFF9800),
          ),
          SizedBox(height: 1.h),
          _buildInsightItem(
            theme,
            'Database Management needs more practice time',
            'priority_high',
            const Color(0xFFF44336),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    ThemeData theme,
    String text,
    String iconName,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(1.5.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(iconName: iconName, color: color, size: 16),
        ),
        SizedBox(width: 3.w),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  Widget _buildDifficultyAnalysis(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject Difficulty Analysis',
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 2.h),
          _buildDifficultyBar(theme, 'Easy', 0.35, const Color(0xFF4CAF50)),
          SizedBox(height: 1.h),
          _buildDifficultyBar(theme, 'Medium', 0.45, const Color(0xFFFF9800)),
          SizedBox(height: 1.h),
          _buildDifficultyBar(theme, 'Hard', 0.20, const Color(0xFFF44336)),
        ],
      ),
    );
  }

  Widget _buildDifficultyBar(
    ThemeData theme,
    String label,
    double value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(
              '${(value * 100).toInt()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLearningVelocity(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Learning Velocity', style: theme.textTheme.titleMedium),
          SizedBox(height: 1.h),
          Text(
            'Your learning pace compared to program average',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildVelocityCard(
                  theme,
                  'Your Pace',
                  '2.5x',
                  'Faster than average',
                  const Color(0xFF4CAF50),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildVelocityCard(
                  theme,
                  'Avg Pace',
                  '1.0x',
                  'Program baseline',
                  theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVelocityCard(
    ThemeData theme,
    String label,
    String value,
    String description,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            description,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
