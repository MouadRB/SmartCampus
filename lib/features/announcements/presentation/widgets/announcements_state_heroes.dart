import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

class AnnouncementsErrorHero extends StatelessWidget {
  const AnnouncementsErrorHero({
    super.key,
    required this.title,
    required this.message,
    required this.tone,
    required this.onRetry,
  });

  final String title;
  final String message;
  final HeroTone tone;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = tone.palette;

    return _CenteredHero(
      icon: tone.icon,
      iconColor: palette.iconColor,
      circleBg: palette.circleBg,
      circleBorder: palette.circleBorder,
      title: title,
      subtitle: message,
      action: _RetryButton(onTap: onRetry),
    );
  }
}

class AnnouncementsEmptyHero extends StatelessWidget {
  const AnnouncementsEmptyHero({
    super.key,
    required this.searchQuery,
    required this.hasActiveFilter,
    required this.onClear,
  });

  final String searchQuery;
  final bool hasActiveFilter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasSearch = searchQuery.isNotEmpty;
    final hasFilter = hasActiveFilter;

    final title = (hasSearch || hasFilter)
        ? 'No Results Found'
        : 'No announcements yet';

    final subtitle = hasSearch
        ? 'No announcements match "$searchQuery"\nTry a different search term or clear your filters.'
        : hasFilter
            ? 'No announcements match the current filter.\nTry a different category or clear your filters.'
            : 'New posts from staff will appear here.';

    return _CenteredHero(
      icon: Icons.search,
      iconColor: AppColors.textTertiary,
      circleBg: AppColors.surface,
      circleBorder: AppColors.border,
      title: title,
      subtitle: subtitle,
      action: (hasSearch || hasFilter)
          ? _ClearSearchButton(onTap: onClear)
          : null,
    );
  }
}

enum HeroTone {
  error(Icons.error_outline_rounded),
  offline(Icons.wifi_off_rounded);

  const HeroTone(this.icon);

  final IconData icon;

  _HeroPalette get palette {
    switch (this) {
      case HeroTone.error:
        return _HeroPalette(
          iconColor: AppColors.error,
          circleBg: AppColors.errorBg,
          circleBorder: AppColors.error,
        );
      case HeroTone.offline:
        return const _HeroPalette(
          iconColor: AppColors.offlineText,
          circleBg: AppColors.offlineBg,
          circleBorder: AppColors.offlineBorder,
        );
    }
  }
}

class _HeroPalette {
  const _HeroPalette({
    required this.iconColor,
    required this.circleBg,
    required this.circleBorder,
  });

  final Color iconColor;
  final Color circleBg;
  final Color circleBorder;
}

class _CenteredHero extends StatelessWidget {
  const _CenteredHero({
    required this.icon,
    required this.iconColor,
    required this.circleBg,
    required this.circleBorder,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final Color circleBg;
  final Color circleBorder;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleBg,
                border: Border.all(color: circleBorder),
              ),
              child: Icon(icon, size: 28.r, color: iconColor),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: AppTextStyles.appBarTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: 24.h),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 16.r, color: AppColors.accent),
            SizedBox(width: 8.w),
            Text(
              'Retry',
              style: AppTextStyles.bodyPrimary.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClearSearchButton extends StatelessWidget {
  const _ClearSearchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'Clear Search',
          style: AppTextStyles.bodyPrimary.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
