import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Certificate action buttons widget for sharing and saving
class CertificateActionButtonsWidget extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onSaveToPhotos;
  final VoidCallback onPrint;

  const CertificateActionButtonsWidget({
    super.key,
    required this.onShare,
    required this.onSaveToPhotos,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary action - Share Certificate
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onShare();
                },
                icon: CustomIconWidget(
                  iconName: 'share',
                  color: theme.colorScheme.onPrimary,
                  size: 5.w,
                ),
                label: Text(
                  'Share Certificate',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Secondary actions row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 6.h,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onSaveToPhotos();
                      },
                      icon: CustomIconWidget(
                        iconName: 'download',
                        color: theme.colorScheme.primary,
                        size: 5.w,
                      ),
                      label: Text(
                        'Save',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: SizedBox(
                    height: 6.h,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onPrint();
                      },
                      icon: CustomIconWidget(
                        iconName: 'print',
                        color: theme.colorScheme.primary,
                        size: 5.w,
                      ),
                      label: Text(
                        'Print',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
