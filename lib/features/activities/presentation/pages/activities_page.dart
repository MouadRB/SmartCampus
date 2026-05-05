import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/activities/domain/entities/activity.dart';
import 'package:smart_campus/features/activities/presentation/bloc/activities_bloc.dart';
import 'package:smart_campus/features/activities/presentation/bloc/activities_event.dart';
import 'package:smart_campus/features/activities/presentation/bloc/activities_state.dart';
import 'package:smart_campus/features/activities/presentation/pages/activity_details_page.dart';
import 'package:smart_campus/features/activities/presentation/widgets/activities_empty_view.dart';
import 'package:smart_campus/features/activities/presentation/widgets/activities_error_view.dart';
import 'package:smart_campus/features/activities/presentation/widgets/activity_card.dart';
import 'package:smart_campus/features/activities/presentation/widgets/skeleton_list.dart';
import 'package:smart_campus/features/activities/presentation/widgets/view_toggle.dart';

/// Reads the global [ActivitiesBloc] from context. The bloc is registered
/// as a singleton at the app root so the home dashboard's "Load Mocks"
/// button and the Events tab share the same loaded list.
class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) => const _ActivitiesScaffold();
}

class _ActivitiesScaffold extends StatefulWidget {
  const _ActivitiesScaffold();

  @override
  State<_ActivitiesScaffold> createState() => _ActivitiesScaffoldState();
}

class _ActivitiesScaffoldState extends State<_ActivitiesScaffold> {
  ActivitiesView _view = ActivitiesView.list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Events'),
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pagePadding.w,
              AppSpacing.paddingCardSm.h,
              AppSpacing.pagePadding.w,
              AppSpacing.paddingCardSm.h,
            ),
            child: ViewToggle(
              value: _view,
              onChanged: (v) => setState(() => _view = v),
            ),
          ),
          Expanded(
            child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
              builder: (context, state) {
                if (state is ActivitiesInitial) {
                  return const ActivitiesEmptyView(
                    subtitle:
                        'Tap "Load Mocks" on the dashboard to seed Constantine campus events.',
                  );
                }
                if (state is ActivitiesLoading) {
                  return const SkeletonList();
                }
                if (state is ActivitiesError) {
                  return ActivitiesErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<ActivitiesBloc>()
                        .add(const FetchActivities()),
                  );
                }
                if (state is ActivitiesLoaded) {
                  if (state.activities.isEmpty) {
                    return const ActivitiesEmptyView();
                  }
                  return _view == ActivitiesView.list
                      ? _ListView(state: state)
                      : _CalendarView(state: state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({required this.state});

  final ActivitiesLoaded state;

  @override
  Widget build(BuildContext context) {
    final monthLabel = state.activities.isEmpty
        ? ''
        : DateFormat('MMMM y')
            .format(state.activities.first.startsAt)
            .toUpperCase();
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        context.read<ActivitiesBloc>().add(const RefreshActivities());
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pagePadding.w,
          AppSpacing.paddingCardSm.h,
          AppSpacing.pagePadding.w,
          AppSpacing.pagePadding.h,
        ),
        itemCount: state.activities.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.cardGap.h),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text(
                'UPCOMING · $monthLabel',
                style: AppTextStyles.eyebrow,
              ),
            );
          }
          final activity = state.activities[i - 1];
          return ActivityCard(
            activity: activity,
            onTap: () => _openDetails(context, activity),
          );
        },
      ),
    );
  }

  void _openDetails(BuildContext context, Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ActivityDetailsPage(activityId: activity.id),
      ),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView({required this.state});

  final ActivitiesLoaded state;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;
    final eventsByDay = _groupByDay(state.activities);
    final selected = state.selectedDay;
    final dayEvents = eventsByDay[_dateKey(selected)] ?? const <Activity>[];
    final firstDay = DateTime.now().subtract(const Duration(days: 30));
    final lastDay = DateTime.now().add(const Duration(days: 365));

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding.w,
        AppSpacing.paddingCardSm.h,
        AppSpacing.pagePadding.w,
        AppSpacing.pagePadding.h,
      ),
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.paddingCardSm.r),
          decoration: glow.cardDecoration,
          child: TableCalendar<Activity>(
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: selected,
            selectedDayPredicate: (d) => isSameDay(d, selected),
            eventLoader: (d) => eventsByDay[_dateKey(d)] ?? const [],
            startingDayOfWeek: StartingDayOfWeek.sunday,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            onDaySelected: (selectedDay, _) {
              context
                  .read<ActivitiesBloc>()
                  .add(SelectCalendarDay(selectedDay));
            },
            headerStyle: HeaderStyle(
              titleCentered: false,
              formatButtonVisible: false,
              titleTextStyle: AppTextStyles.sectionHeader,
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: AppColors.textSecondary,
                size: 20.r,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20.r,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: AppTextStyles.bodySecondary,
              weekendStyle: AppTextStyles.bodySecondary,
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: AppTextStyles.bodyPrimary,
              weekendTextStyle: AppTextStyles.bodyPrimary,
              todayDecoration: BoxDecoration(
                color: AppColors.accentSubtle,
                shape: BoxShape.circle,
              ),
              todayTextStyle: AppTextStyles.bodyPrimary
                  .copyWith(color: AppColors.accent, fontWeight: FontWeight.w700),
              selectedDecoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: AppTextStyles.bodyPrimary.copyWith(
                color: AppColors.background,
                fontWeight: FontWeight.w700,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              markerSize: 5,
              markersAlignment: Alignment.bottomCenter,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sectionGap.h),
        Text(
          dayEvents.isEmpty
              ? 'NO EVENTS ON ${DateFormat('MMMM d').format(selected).toUpperCase()}'
              : '${dayEvents.length} EVENT${dayEvents.length == 1 ? '' : 'S'} ON ${DateFormat('MMMM d').format(selected).toUpperCase()}',
          style: AppTextStyles.eyebrow,
        ),
        SizedBox(height: 12.h),
        if (dayEvents.isEmpty)
          const ActivitiesEmptyView(
            subtitle: 'Pick another day to see scheduled activities.',
          )
        else
          ...dayEvents.expand((a) => [
                ActivityCard(
                  activity: a,
                  onTap: () => _openDetails(context, a),
                ),
                SizedBox(height: AppSpacing.cardGap.h),
              ]),
      ],
    );
  }

  Map<DateTime, List<Activity>> _groupByDay(List<Activity> activities) {
    final map = <DateTime, List<Activity>>{};
    for (final a in activities) {
      final key = _dateKey(a.startsAt);
      (map[key] ??= []).add(a);
    }
    return map;
  }

  DateTime _dateKey(DateTime d) => DateTime(d.year, d.month, d.day);

  void _openDetails(BuildContext context, Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ActivityDetailsPage(activityId: activity.id),
      ),
    );
  }
}
