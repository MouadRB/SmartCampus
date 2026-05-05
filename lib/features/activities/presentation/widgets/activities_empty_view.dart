import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

/// Neutral empty state shown when the upcoming list comes back empty.
class ActivitiesEmptyView extends StatelessWidget {
  const ActivitiesEmptyView({super.key, this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.pagePadding.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                Icons.event_available_outlined,
                color: AppColors.accent,
                size: 28.r,
              ),
            ),
            SizedBox(height: 12.h),
            Text('Nothing scheduled', style: AppTextStyles.sectionHeader),
            SizedBox(height: 6.h),
            Text(
              subtitle ?? 'Check back later for upcoming campus activities.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
