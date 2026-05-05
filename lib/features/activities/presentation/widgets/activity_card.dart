import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/activities/domain/entities/activity.dart';
import 'category_chip.dart';
import 'date_badge.dart';

/// One row in the upcoming-activities list. Matches the design screenshot:
/// left-side date pill, embedded card with category chip + title + time +
/// location, trailing chevron.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.paddingCardSm.r),
          decoration: glow.cardDecoration.copyWith(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DateBadge(date: activity.startsAt),
              SizedBox(width: AppSpacing.cardGap.w),
              Expanded(child: _CardBody(activity: activity)),
              Icon(
                Icons.chevron_right,
                size: 20.r,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.paddingCardSm.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusIcon.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CategoryChip(category: activity.category),
          ),
          SizedBox(height: 6.h),
          Text(
            activity.title,
            style: AppTextStyles.bodyPrimary
                .copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          _IconLine(
            icon: Icons.access_time,
            text: _timeRange(activity),
          ),
          SizedBox(height: 4.h),
          _IconLine(
            icon: Icons.place_outlined,
            text: activity.location,
          ),
        ],
      ),
    );
  }

  String _timeRange(Activity a) {
    final start = DateFormat('HH:mm').format(a.startsAt);
    final end = a.endsAt == null ? null : DateFormat('HH:mm').format(a.endsAt!);
    return end == null ? start : '$start – $end';
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14.r, color: AppColors.textTertiary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
