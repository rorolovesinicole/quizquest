import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Individual program card widget with themed artwork and progress
class ProgramCardWidget extends StatelessWidget {
  final Map<String, dynamic> program;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ProgramCardWidget({
    super.key,
    required this.program,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isStarted = program['isStarted'] as bool;
    final isCompleted = program['isCompleted'] as bool;
    final progress = program['progress'] as double;
    final themeColor = Color(program['themeColor'] as int);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: CustomImageWidget(
                imageUrl: program['imageUrl'] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                semanticLabel: program['semanticLabel'] as String,
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(1.5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Abbreviation and completion badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 1.w,
                          vertical: 0.3.h,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          program['abbreviation'] as String,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 9.sp,
                          ),
                        ),
                      ),

                      if (isCompleted)
                        Container(
                          padding: EdgeInsets.all(0.8.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: 'emoji_events',
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // Program name
                  Text(
                    program['fullName'] as String,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      fontSize: 10.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 0.4.h),

                  // Dynamic Stars (Zones Cleared)
                  Row(
                    children: List.generate(3, (index) {
                      final stars = (program['stars'] as int?) ?? 0;
                      return Padding(
                        padding: EdgeInsets.only(right: 1.w),
                        child: CustomIconWidget(
                          iconName: index < stars ? 'star' : 'star_border',
                          color: index < stars
                              ? theme.colorScheme.tertiary
                              : Colors.white.withValues(alpha: 0.5),
                          size: 16,
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: 0.4.h),

                  // Estimated time
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 12,
                      ),
                      SizedBox(width: 0.5.w),
                      Text(
                        program['estimatedTime'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10.sp,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),

                  // Progress bar (if started)
                  if (isStarted) ...[
                    SizedBox(height: 0.4.h),
                    SizedBox(height: 0.5.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        minHeight: 0.6.h,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      '${(progress * 100).toInt()}% Complete',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  // Achievement badges
                  if ((program['achievements'] as List).isNotEmpty) ...[
                    SizedBox(height: 0.8.h),
                    Wrap(
                      spacing: 1.w,
                      children: (program['achievements'] as List).take(2).map((
                        achievement,
                      ) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 1.5.w,
                            vertical: 0.3.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary.withValues(
                              alpha: 0.9,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'military_tech',
                                color: Colors.white,
                                size: 10,
                              ),
                              SizedBox(width: 0.5.w),
                              Text(
                                achievement as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
