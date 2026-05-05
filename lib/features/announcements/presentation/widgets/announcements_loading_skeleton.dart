import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/presentation/widgets/skeleton_block.dart';
import 'package:smart_campus/core/theme/app_theme.dart';

class AnnouncementsLoadingSkeleton extends StatelessWidget {
  const AnnouncementsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding.w,
        AppSpacing.paddingCard.h,
        AppSpacing.pagePadding.w,
        AppSpacing.paddingCard.h,
      ),
      sliver: SliverList.list(
        children: [
          const SkeletonBlock(height: 44, radius: AppSpacing.radiusCard),
          SizedBox(height: 14.h),
          SizedBox(
            height: 32.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, i) => const SkeletonBlock(
                width: 64,
                height: 32,
                radius: 999,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          for (var i = 0; i < 5; i++) ...[
            const _ListItemSkeleton(),
            if (i < 4) SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}

class _ListItemSkeleton extends StatelessWidget {
  const _ListItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3.w, color: AppColors.border),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBlock(width: 80, height: 12),
                    SizedBox(height: 10.h),
                    const SkeletonBlock(height: 14),
                    SizedBox(height: 6.h),
                    const SkeletonBlock(width: 200, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
