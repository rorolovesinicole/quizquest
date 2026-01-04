import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Detailed program overview modal with course description and level breakdown
class ProgramDetailModal extends StatelessWidget {
  final Map<String, dynamic> program;

  const ProgramDetailModal({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColor = Color(program['themeColor'] as int);
    final difficulty = program['difficulty'] as int;
    final zones = program['zones'] as List;
    final isStarted = program['isStarted'] as bool;
    final progress = program['progress'] as double;

    return Container(
      height: 85.h,
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

          // Header image
          SizedBox(
            height: 25.h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomImageWidget(
                    imageUrl: program['imageUrl'] as String,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    semanticLabel: program['semanticLabel'] as String,
                  ),
                ),

                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, theme.colorScheme.surface],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 2.h,
                  right: 4.w,
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Program header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          program['abbreviation'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: themeColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              program['fullName'] as String,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: List.generate(5, (index) {
                                return Padding(
                                  padding: EdgeInsets.only(right: 0.5.w),
                                  child: CustomIconWidget(
                                    iconName: index < difficulty
                                        ? 'star'
                                        : 'star_border',
                                    color: index < difficulty
                                        ? theme.colorScheme.tertiary
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.3),
                                    size: 16,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: 'schedule',
                          label: 'Duration',
                          value: program['estimatedTime'] as String,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: 'layers',
                          label: 'Levels',
                          value: '${program['levelCount']} levels',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Description
                  Text(
                    'About This Program',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    program['description'] as String,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),

                  SizedBox(height: 3.h),

                  // Learning zones
                  Text(
                    'Learning Zones',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ...zones.asMap().entries.map((entry) {
                    final index = entry.key;
                    final zone = entry.value as String;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: themeColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(zone, style: theme.textTheme.bodyLarge),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Progress section (if started)
                  if (isStarted) ...[
                    SizedBox(height: 3.h),
                    Text(
                      'Your Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        minHeight: 1.h,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '${(progress * 100).toInt()}% Complete • ${((program['levelCount'] as int) * progress).toInt()} of ${program['levelCount']} levels',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  if (isStarted)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('View Progress'),
                      ),
                    ),

                  if (isStarted) SizedBox(width: 3.w),

                  Expanded(
                    flex: isStarted ? 1 : 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.gameWorldMap,
                          arguments: {'programId': program['id']},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                      ),
                      child: Text(isStarted ? 'Continue' : 'Start Program'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
