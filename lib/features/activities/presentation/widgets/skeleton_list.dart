import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

/// Shimmering placeholder list shown during the initial fetch. Mirrors the
/// rough geometry of an [ActivityCard] so the transition to real content
/// doesn't cause visible reflow.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.borderLight,
      period: const Duration(milliseconds: 1400),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding.w,
          vertical: AppSpacing.paddingCard.h,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.cardGap.h),
        itemBuilder: (_, __) => const _SkeletonCard(),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
      ),
    );
  }
}
