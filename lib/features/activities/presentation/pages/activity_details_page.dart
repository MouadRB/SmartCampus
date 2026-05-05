import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/activities/domain/entities/activity.dart';
import 'package:smart_campus/features/activities/presentation/bloc/activities_bloc.dart';
import 'package:smart_campus/features/activities/presentation/bloc/activities_event.dart';
import 'package:smart_campus/features/activities/presentation/bloc/activities_state.dart';
import 'package:smart_campus/features/activities/presentation/widgets/attendance_bar.dart';
import 'package:smart_campus/features/activities/presentation/widgets/category_chip.dart';

/// Single-activity detail screen. Reads the live entity from the parent
/// [ActivitiesBloc] (so RSVP toggles re-render without a re-fetch) and falls
/// back to the snapshot passed via [activityId] if state regresses.
class ActivityDetailsPage extends StatelessWidget {
  const ActivityDetailsPage({super.key, required this.activityId});

  final int activityId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<ActivitiesBloc, ActivitiesState>(
        builder: (context, state) {
          if (state is! ActivitiesLoaded) {
            return const SizedBox.shrink();
          }
          final activity = state.activities.firstWhere(
            (a) => a.id == activityId,
            orElse: () => state.activities.first,
          );
          return _DetailsBody(activity: activity);
        },
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding.w,
        AppSpacing.pagePadding.h,
        AppSpacing.pagePadding.w,
        (AppSpacing.pagePadding + 24).h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CoverPlaceholder(),
          SizedBox(height: AppSpacing.sectionGap.h),
          Align(
            alignment: Alignment.centerLeft,
            child: CategoryChip(category: activity.category),
          ),
          SizedBox(height: 8.h),
          Text(
            activity.title,
            style: AppTextStyles.greetingName,
          ),
          SizedBox(height: AppSpacing.sectionGap.h),
          _InfoCard(activity: activity),
          SizedBox(height: AppSpacing.sectionGap.h),
          AttendanceBar(
            attendance: activity.attendance,
            capacity: activity.capacity,
          ),
          SizedBox(height: AppSpacing.sectionGap.h),
          Text('ABOUT', style: AppTextStyles.eyebrow),
          SizedBox(height: 8.h),
          Text(
            activity.aboutLong ?? activity.description,
            style: AppTextStyles.bodyPrimary
                .copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
          SizedBox(height: 28.h),
          _RsvpButton(activity: activity),
        ],
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textTertiary,
              size: 24.r,
            ),
          ),
          SizedBox(height: 8.h),
          Text('EVENT COVER', style: AppTextStyles.eyebrow),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;
    return Container(
      padding: EdgeInsets.all(AppSpacing.paddingCard.r),
      decoration: glow.cardDecoration,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.access_time,
            label: 'Date & Time',
            value: _formatWhen(activity),
          ),
          SizedBox(height: 14.h),
          Container(height: 1, color: AppColors.border),
          SizedBox(height: 14.h),
          _InfoRow(
            icon: Icons.place_outlined,
            label: 'Location',
            value: activity.location,
          ),
        ],
      ),
    );
  }

  String _formatWhen(Activity a) {
    final day = DateFormat('EEE, MMM d').format(a.startsAt);
    final start = DateFormat('HH:mm').format(a.startsAt);
    if (a.endsAt == null) return '$day · $start';
    final end = DateFormat('HH:mm').format(a.endsAt!);
    return '$day · $start – $end';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: AppColors.accentSubtle,
            borderRadius: BorderRadius.circular(AppSpacing.radiusIcon.r),
          ),
          child: Icon(icon, color: AppColors.accent, size: 18.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySecondary),
              SizedBox(height: 2.h),
              Text(value, style: AppTextStyles.bodyPrimary),
            ],
          ),
        ),
      ],
    );
  }
}

class _RsvpButton extends StatelessWidget {
  const _RsvpButton({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;
    final going = activity.rsvpStatus == RsvpStatus.going;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
          boxShadow: going ? const [] : glow.accentGlowLg,
        ),
        child: FilledButton(
          onPressed: () => context
              .read<ActivitiesBloc>()
              .add(ToggleRsvp(activity.id)),
          style: FilledButton.styleFrom(
            backgroundColor:
                going ? AppColors.surface : AppColors.accent,
            foregroundColor:
                going ? AppColors.textPrimary : AppColors.background,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
              side: BorderSide(
                color: going ? AppColors.border : Colors.transparent,
              ),
            ),
          ),
          child: Text(
            going ? "You're going · Cancel RSVP" : 'RSVP for this Event',
            style: AppTextStyles.bodyPrimary.copyWith(
              color:
                  going ? AppColors.textPrimary : AppColors.background,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
