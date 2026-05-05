import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/presentation/widgets/skeleton_block.dart';
import 'package:smart_campus/core/theme/app_theme.dart';

class HomeLoadingSkeleton extends StatelessWidget {
  const HomeLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding.w,
        AppSpacing.paddingCard.h,
        AppSpacing.pagePadding.w,
        (AppSpacing.paddingCard + 24).h,
      ),
      sliver: SliverList.list(
        children: [
          const SkeletonBlock(width: 96, height: 12),
          SizedBox(height: 8.h),
          const SkeletonBlock(width: 168, height: 18),
          SizedBox(height: AppSpacing.sectionGap.h),

          const SkeletonBlock(height: 96, radius: AppSpacing.radiusCard),
          SizedBox(height: AppSpacing.sectionGap.h),

          const SkeletonBlock(width: 100, height: 14),
          SizedBox(height: 12.h),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              4,
              (_) => const _PulseFill(radius: AppSpacing.radiusCard),
            ),
          ),
          SizedBox(height: AppSpacing.sectionGap.h),

          const SkeletonBlock(width: 130, height: 14),
          SizedBox(height: 12.h),
          SizedBox(
            height: 108.h,
            child: Row(
              children: [
                const Expanded(
                  child: _PulseFill(radius: AppSpacing.radiusCard),
                ),
                SizedBox(width: 12.w),
                const Expanded(
                  child: _PulseFill(radius: AppSpacing.radiusCard),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sectionGap.h),

          const SkeletonBlock(width: 140, height: 14),
          SizedBox(height: 12.h),
          const SkeletonBlock(height: 70, radius: AppSpacing.radiusCard),
          SizedBox(height: 12.h),
          const SkeletonBlock(height: 70, radius: AppSpacing.radiusCard),
        ],
      ),
    );
  }
}

class _PulseFill extends StatefulWidget {
  const _PulseFill({this.radius});

  final double? radius;

  @override
  State<_PulseFill> createState() => _PulseFillState();
}

class _PulseFillState extends State<_PulseFill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _color = ColorTween(
      begin: AppColors.border.withValues(alpha: 0.70),
      end: AppColors.borderLight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (_, __) => DecoratedBox(
        decoration: BoxDecoration(
          color: _color.value,
          borderRadius: BorderRadius.circular(
            (widget.radius ?? AppSpacing.radiusIcon).r,
          ),
        ),
      ),
    );
  }
}
