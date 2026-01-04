import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Answer options widget with haptic feedback and animations
class AnswerOptionsWidget extends StatefulWidget {
  final List<String> options;
  final int? selectedIndex;
  final Function(int) onOptionSelected;
  final bool isAnswered;
  final int? correctIndex;
  final List<int> eliminatedIndices;

  const AnswerOptionsWidget({
    super.key,
    required this.options,
    this.selectedIndex,
    required this.onOptionSelected,
    this.isAnswered = false,
    this.correctIndex,
    this.eliminatedIndices = const [],
  });

  @override
  State<AnswerOptionsWidget> createState() => _AnswerOptionsWidgetState();
}

class _AnswerOptionsWidgetState extends State<AnswerOptionsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int? _tappedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (widget.isAnswered || widget.eliminatedIndices.contains(index)) return;

    setState(() => _tappedIndex = index);
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    HapticFeedback.lightImpact();
    widget.onOptionSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.options.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
      itemBuilder: (context, index) {
        final isSelected = widget.selectedIndex == index;
        final isCorrect = widget.correctIndex == index;
        final showResult = widget.isAnswered;
        final isEliminated = widget.eliminatedIndices.contains(index);

        Color backgroundColor;
        Color borderColor;
        Color textColor;

        if (isEliminated) {
           backgroundColor = colorScheme.surface.withValues(alpha: 0.5);
           borderColor = colorScheme.outline.withValues(alpha: 0.1);
           textColor = colorScheme.onSurface.withValues(alpha: 0.3);
        } else if (showResult) {
          if (isCorrect) {
            backgroundColor = AppTheme.successLight.withValues(alpha: 0.15);
            borderColor = AppTheme.successLight;
            textColor = AppTheme.successLight;
          } else if (isSelected && !isCorrect) {
            backgroundColor = AppTheme.errorLight.withValues(alpha: 0.15);
            borderColor = AppTheme.errorLight;
            textColor = AppTheme.errorLight;
          } else {
            backgroundColor = colorScheme.surface;
            borderColor = colorScheme.outline.withValues(alpha: 0.3);
            textColor = colorScheme.onSurface;
          }
        } else if (isSelected) {
          backgroundColor = colorScheme.primaryContainer.withValues(alpha: 0.2);
          borderColor = colorScheme.primary;
          textColor = colorScheme.primary;
        } else {
          backgroundColor = colorScheme.surface;
          borderColor = colorScheme.outline.withValues(alpha: 0.3);
          textColor = colorScheme.onSurface;
        }

        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final scale = _tappedIndex == index ? _scaleAnimation.value : 1.0;
            return Transform.scale(scale: scale, child: child);
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleTap(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: isSelected && !showResult
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Option letter
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: borderColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Option text
                    Expanded(
                      child: Text(
                        widget.options[index],
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: textColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),

                    // Result icon
                    if (showResult &&
                        (isCorrect || (isSelected && !isCorrect))) ...[
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: isCorrect ? 'check_circle' : 'cancel',
                        color: isCorrect
                            ? AppTheme.successLight
                            : AppTheme.errorLight,
                        size: 24,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
