import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Question content widget supporting multiple question formats
class QuestionContentWidget extends StatelessWidget {
  final String questionText;
  final String? imageUrl;
  final String? imageSemanticLabel;
  final String questionType;

  const QuestionContentWidget({
    super.key,
    required this.questionText,
    this.imageUrl,
    this.imageSemanticLabel,
    required this.questionType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question type badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: _getQuestionTypeColor(
                questionType,
                colorScheme,
              ).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: _getQuestionTypeIcon(questionType),
                  color: _getQuestionTypeColor(questionType, colorScheme),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  _getQuestionTypeLabel(questionType),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _getQuestionTypeColor(questionType, colorScheme),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Question text
          Text(
            questionText,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),

          // Image for identification questions
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImageWidget(
                imageUrl: imageUrl!,
                width: double.infinity,
                height: 25.h,
                fit: BoxFit.cover,
                semanticLabel: imageSemanticLabel ?? 'Question image',
              ),
            ),
          ],

          // Instruction text based on question type
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info_outline',
                  color: colorScheme.primary,
                  size: 18,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    _getInstructionText(questionType),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getQuestionTypeColor(String type, ColorScheme colorScheme) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return colorScheme.primary;
      case 'true_false':
        return AppTheme.successLight;
      case 'image_identification':
        return AppTheme.warningLight;
      case 'scenario':
        return colorScheme.secondary;
      default:
        return colorScheme.primary;
    }
  }

  String _getQuestionTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return 'radio_button_checked';
      case 'true_false':
        return 'check_circle';
      case 'image_identification':
        return 'image';
      case 'scenario':
        return 'psychology';
      default:
        return 'help_outline';
    }
  }

  String _getQuestionTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return 'Multiple Choice';
      case 'true_false':
        return 'True/False';
      case 'image_identification':
        return 'Image ID';
      case 'scenario':
        return 'Scenario';
      default:
        return 'Question';
    }
  }

  String _getInstructionText(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return 'Tap to select the correct answer';
      case 'true_false':
        return 'Swipe left for False, right for True';
      case 'image_identification':
        return 'Tap the correct area in the image';
      case 'scenario':
        return 'Choose the best solution';
      default:
        return 'Select your answer';
    }
  }
}
