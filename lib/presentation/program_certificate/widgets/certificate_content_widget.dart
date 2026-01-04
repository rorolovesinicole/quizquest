import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Certificate content widget displaying student details and achievement summary
class CertificateContentWidget extends StatelessWidget {
  final String studentName;
  final String programTitle;
  final String completionDate;
  final String overallAccuracy;
  final String totalStudyTime;
  final int achievementCount;

  const CertificateContentWidget({
    super.key,
    required this.studentName,
    required this.programTitle,
    required this.completionDate,
    required this.overallAccuracy,
    required this.totalStudyTime,
    required this.achievementCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Decorative line
        Container(
          width: 20.w,
          height: 0.3.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: 3.h),

        // "This certifies that" text
        Text(
          'This certifies that',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),

        // Student name
        Text(
          studentName,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
            fontSize: 24.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),

        // "has successfully completed" text
        Text(
          'has successfully completed',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),

        // Program title
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            programTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 3.h),

        // Completion date
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'calendar_today',
              color: theme.colorScheme.onSurfaceVariant,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Completed on $completionDate',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Performance summary
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Performance Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    'Accuracy',
                    overallAccuracy,
                    'check_circle',
                  ),
                  _buildStatItem(
                    context,
                    'Study Time',
                    totalStudyTime,
                    'schedule',
                  ),
                  _buildStatItem(
                    context,
                    'Achievements',
                    achievementCount.toString(),
                    'emoji_events',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    String iconName,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: theme.colorScheme.primary,
          size: 6.w,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
