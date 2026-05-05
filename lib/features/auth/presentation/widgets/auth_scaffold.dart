import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

/// Shared chrome for [LoginPage] and [SignUpPage]: glow-rim logo, brand
/// name, page-specific title + subtitle, and the scrollable content body.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding.w,
            vertical: AppSpacing.sectionGap.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12.h),
              _LogoBadge(glow: glow),
              SizedBox(height: 12.h),
              Text(
                'SMARTCAMPUS',
                textAlign: TextAlign.center,
                style: AppTextStyles.eyebrow.copyWith(
                  letterSpacing: 2.4,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.greetingName.copyWith(fontSize: 24.sp),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.bodySecondary.copyWith(height: 1.5),
                ),
              ),
              SizedBox(height: AppSpacing.sectionGap.h),
              child,
              SizedBox(height: 24.h),
              Text(
                '· Secure connection · End-to-end encrypted ·',
                textAlign: TextAlign.center,
                style: AppTextStyles.micro,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.glow});

  final AppGlowTheme glow;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 64.r,
        height: 64.r,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
          boxShadow: glow.accentGlowMd,
        ),
        child: Icon(
          Icons.school_outlined,
          color: AppColors.accent,
          size: 30.r,
        ),
      ),
    );
  }
}
