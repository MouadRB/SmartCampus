import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/home/presentation/widgets/quick_actions_grid.dart';

class HomeNewUserEmpty extends StatelessWidget {
  const HomeNewUserEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pagePadding.w,
          AppSpacing.paddingCard.h,
          AppSpacing.pagePadding.w,
          AppSpacing.paddingCard.h,
        ),
        child: Column(
          children: [
            QuickActionsGrid(onAction: (_) {}),
            const Expanded(child: Center(child: _HeroEmpty())),
          ],
        ),
      ),
    );
  }
}

class _HeroEmpty extends StatelessWidget {
  const _HeroEmpty();

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80.r,
            height: 80.r,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    size: 36.r,
                    color: AppColors.textSecondary,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 4.r,
                  child: Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                      boxShadow: glow.accentGlowSm,
                    ),
                    child: Icon(
                      Icons.bolt,
                      size: 14.r,
                      color: AppColors.background,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Welcome to SmartCampus',
            style: AppTextStyles.appBarTitle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your schedule to see classes, assignments, and campus activity all in one place.',
            style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          const _AccentCta(label: 'Add Your Schedule'),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Text(
                'Browse Campus Events',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentCta extends StatefulWidget {
  const _AccentCta({required this.label});

  final String label;

  @override
  State<_AccentCta> createState() => _AccentCtaState();
}

class _AccentCtaState extends State<_AccentCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {},
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
            boxShadow: glow.accentGlowLg,
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.background,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
