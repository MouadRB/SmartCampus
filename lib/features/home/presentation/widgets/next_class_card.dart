import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:smart_campus/features/timetable/presentation/bloc/timetable_state.dart';

class NextClassCard extends StatefulWidget {
  const NextClassCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<NextClassCard> createState() => _NextClassCardState();
}

class _NextClassCardState extends State<NextClassCard> {
  bool _pressed = false;

  String _resolveTitle(TimetableState state) {
    if (state is! TimetableLoaded) return 'No upcoming class';
    for (final t in state.tasks) {
      if (!t.completed) return t.title;
    }
    return 'No upcoming class';
  }

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;

    return BlocBuilder<TimetableBloc, TimetableState>(
      builder: (context, state) {
        final title = _resolveTitle(state);

        return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.paddingCard.r),
              decoration: glow.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO(campus-task-entity): map subtitle / countdown / countdownUnit
                  // from CampusTask.room, .professor, .startTime, .endTime once the
                  // Domain entity adds those fields. Today CampusTask only exposes
                  // {id, userId, title, completed}.
                  _ClassHeader(
                    eyebrow: 'UP NEXT',
                    title: title,
                    subtitle: 'Room A-304 · Prof. Martinez',
                    countdown: '47',
                    countdownUnit: 'min left',
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      // TODO(campus-task-entity): derive progress from
                      // (now − startTime) / (endTime − startTime).
                      Expanded(
                        child: _NeonProgressBar(progress: 0.35, glow: glow),
                      ),
                      SizedBox(width: 10.w),
                      // TODO(campus-task-entity): format from startTime / endTime.
                      Text(
                        '10:00–11:30 AM',
                        style: AppTextStyles.micro.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClassHeader extends StatelessWidget {
  const _ClassHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.countdown,
    required this.countdownUnit,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String countdown;
  final String countdownUnit;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(999.r),
                      boxShadow: glow.accentGlowMd,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(eyebrow, style: AppTextStyles.eyebrow),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                title,
                style: AppTextStyles.bodyPrimary.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(subtitle, style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              countdown,
              style: AppTextStyles.countdown.copyWith(
                shadows: glow.accentGlowMd
                    .map(
                      (s) => Shadow(color: s.color, blurRadius: s.blurRadius),
                    )
                    .toList(),
              ),
            ),
            Text(
              countdownUnit,
              style: AppTextStyles.micro.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NeonProgressBar extends StatelessWidget {
  const _NeonProgressBar({required this.progress, required this.glow});

  final double progress;
  final AppGlowTheme glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4.h,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: const SizedBox.expand(),
            ),
            Container(
              width: constraints.maxWidth * progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(999.r),
                boxShadow: glow.accentGlowSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
