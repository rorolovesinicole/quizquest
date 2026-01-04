import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Purchase Confirmation Sheet
///
/// Bottom sheet modal for confirming gem purchases
/// Features:
/// - Item preview
/// - Cost display
/// - Current balance check
/// - Clear confirm/cancel actions
class PurchaseConfirmationSheet extends StatelessWidget {
  final Map<String, dynamic> item;
  final int currentGemBalance;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PurchaseConfirmationSheet({
    super.key,
    required this.item,
    required this.currentGemBalance,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cost = item['cost'] as int;
    final canAfford = currentGemBalance >= cost;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
      ),
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          SizedBox(height: 3.h),

          // Title
          Text('Purchase Item', style: theme.textTheme.headlineSmall),
          SizedBox(height: 3.h),

          // Item preview
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(color: theme.dividerColor, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.w),
              child: CustomImageWidget(
                imageUrl: item['image'] as String,
                fit: BoxFit.cover,
                semanticLabel: item['semanticLabel'] as String,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Item name
          Text(
            item['name'] as String,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),

          // Cost display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'diamond',
                  color: const Color(0xFF6B73FF),
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  cost.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF6B73FF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 2.w),
                Text('Gems', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Balance display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Balance: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                currentGemBalance.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: canAfford
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 1.w),
              CustomIconWidget(
                iconName: 'diamond',
                color: canAfford
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
                size: 16,
              ),
            ],
          ),

          if (!canAfford) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: const Color(0xFFF44336),
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Insufficient gems',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFF44336),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 4.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: canAfford ? onConfirm : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  ),
                  child: const Text('Purchase'),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
