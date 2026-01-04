import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Program Breakdown Widget
///
/// Displays detailed performance breakdown by program including:
/// - Program comparison horizontal bar chart
/// - Individual program performance cards
/// - Subject-wise accuracy breakdown
/// - Completion rates per program
class ProgramBreakdownWidget extends StatelessWidget {
  final String selectedProgram;
  final DateTimeRange dateRange;

  const ProgramBreakdownWidget({
    super.key,
    required this.selectedProgram,
    required this.dateRange,
  });

  // Mock program data
  final List<Map<String, dynamic>> _programData = const [
    {
      "program": "BSIT",
      "accuracy": 92.5,
      "completion": 96.0,
      "quizzes": 45,
      "studyTime": "18h 24m",
      "color": 0xFF4A90E2,
    },
    {
      "program": "BSCS",
      "accuracy": 88.0,
      "completion": 94.0,
      "quizzes": 38,
      "studyTime": "15h 12m",
      "color": 0xFF6B73FF,
    },
    {
      "program": "BSCpE",
      "accuracy": 85.5,
      "completion": 90.0,
      "quizzes": 32,
      "studyTime": "12h 48m",
      "color": 0xFF4CAF50,
    },
    {
      "program": "BSBA",
      "accuracy": 83.0,
      "completion": 88.0,
      "quizzes": 28,
      "studyTime": "10h 36m",
      "color": 0xFFFF9800,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredData = selectedProgram == 'All Programs'
        ? _programData
        : _programData.where((p) => p["program"] == selectedProgram).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonChart(theme, filteredData),
          SizedBox(height: 3.h),
          _buildProgramCards(theme, filteredData),
        ],
      ),
    );
  }

  Widget _buildComparisonChart(
    ThemeData theme,
    List<Map<String, dynamic>> data,
  ) {
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
          Text('Program Comparison', style: theme.textTheme.titleMedium),
          SizedBox(height: 1.h),
          Text(
            'Accuracy by Program',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 250,
            child: Semantics(
              label: 'Program Comparison Bar Chart',
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final program = data[groupIndex]["program"] as String;
                        final accuracy = data[groupIndex]["accuracy"] as double;
                        return BarTooltipItem(
                          '$program\n$accuracy%',
                          theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < data.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 1.h),
                              child: Text(
                                data[value.toInt()]["program"] as String,
                                style: theme.textTheme.labelSmall,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outlineVariant,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    data.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data[index]["accuracy"] as double,
                          color: Color(data[index]["color"] as int),
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
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
    );
  }

  Widget _buildProgramCards(ThemeData theme, List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Program Details', style: theme.textTheme.titleMedium),
        SizedBox(height: 2.h),
        ...data.map((program) => _buildProgramCard(theme, program)),
      ],
    );
  }

  Widget _buildProgramCard(ThemeData theme, Map<String, dynamic> program) {
    final programName = program["program"] as String;
    final accuracy = program["accuracy"] as double;
    final completion = program["completion"] as double;
    final quizzes = program["quizzes"] as int;
    final studyTime = program["studyTime"] as String;
    final color = Color(program["color"] as int);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'school',
                  color: color,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      programName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$quizzes quizzes completed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'Accuracy',
                  '$accuracy%',
                  'check_circle',
                  color,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'Completion',
                  '$completion%',
                  'task_alt',
                  color,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'Study Time',
                  studyTime,
                  'schedule',
                  color,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'Quizzes',
                  '$quizzes',
                  'quiz',
                  color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    ThemeData theme,
    String label,
    String value,
    String iconName,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(iconName: iconName, color: color, size: 16),
              SizedBox(width: 1.w),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
