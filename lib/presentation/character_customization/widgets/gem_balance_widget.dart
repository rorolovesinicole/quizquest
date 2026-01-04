import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Gem Balance Widget
///
/// Displays user's current gem balance
/// Features:
/// - Prominent display at top of screen
/// - Animated gem icon
/// - Clear balance formatting
class GemBalanceWidget extends StatelessWidget {
  final int gemBalance;

  const GemBalanceWidget({super.key, required this.gemBalance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B73FF), Color(0xFF4A90E2)],
              ),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'diamond',
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            'Gems:',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            gemBalance.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFF6B73FF),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
