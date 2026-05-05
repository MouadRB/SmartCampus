import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/activities/presentation/pages/activities_page.dart';
import 'package:smart_campus/features/timetable/domain/entities/campus_task.dart';
import 'package:smart_campus/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:smart_campus/features/timetable/presentation/bloc/timetable_state.dart';

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({super.key});

  static const _maxTiles = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Upcoming Events',
          onSeeAll: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ActivitiesPage(),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        BlocBuilder<TimetableBloc, TimetableState>(
          builder: (context, state) {
            final tasks = state is TimetableLoaded
                ? state.tasks.where((t) => !t.completed).take(_maxTiles).toList()
                : const <CampusTask>[];

            if (tasks.isEmpty) return const SizedBox.shrink();

            return Column(
              children: [
                for (var i = 0; i < tasks.length; i++) ...[
                  _EventTile(task: tasks[i]),
                  if (i < tasks.length - 1) SizedBox(height: 12.h),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.sectionHeader),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Text(
              'See All',
              style: AppTextStyles.navLabel.copyWith(color: AppColors.accent),
            ),
          ),
        ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.task});

  final CampusTask task;

  // TODO(campus-task-entity): replace neutral fallbacks with real values once
  // CampusTask gains startTime / endTime / location. The Domain entity today
  // exposes only {id, userId, title, completed}, so day / date / time /
  // location cannot yet be derived.
  static const _dayFallback = 'TBD';
  static const _dateFallback = '–';
  static const _timeFallback = 'TBD';
  static const _locationFallback = 'TBD';

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;

    return Container(
      padding: EdgeInsets.all(AppSpacing.paddingCardSm.r),
      decoration: glow.cardDecoration,
      child: Row(
        children: [
          const _DateChip(day: _dayFallback, date: _dateFallback),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.bodyPrimary.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '$_timeFallback · $_locationFallback',
                  style: AppTextStyles.micro,
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.chevron_right,
            size: 14.r,
            color: AppColors.border,
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.day, required this.date});

  final String day;
  final String date;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;

    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: AppColors.accentSubtle,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: AppTextStyles.eyebrow.copyWith(
              fontSize: 9.sp,
              letterSpacing: 0.4,
              color: AppColors.accent.withValues(alpha: 0.70),
              height: 1.0,
            ),
          ),
          Text(
            date,
            style: AppTextStyles.countdown.copyWith(
              fontSize: 16.sp,
              height: 1.15,
              shadows: glow.accentGlowMd
                  .map((s) => Shadow(color: s.color, blurRadius: s.blurRadius))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
