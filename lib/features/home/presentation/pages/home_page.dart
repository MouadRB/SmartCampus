import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/connectivity/connectivity_bloc.dart';
import 'package:smart_campus/core/connectivity/connectivity_state.dart';
import 'package:smart_campus/core/presentation/widgets/app_top_bar.dart';
import 'package:smart_campus/core/presentation/widgets/offline_banner.dart';
import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_state.dart';
import 'package:smart_campus/features/home/presentation/widgets/greeting_header.dart';
import 'package:smart_campus/features/home/presentation/widgets/home_loading_skeleton.dart';
import 'package:smart_campus/features/home/presentation/widgets/home_new_user_empty.dart';
import 'package:smart_campus/features/home/presentation/widgets/next_class_card.dart';
import 'package:smart_campus/features/home/presentation/widgets/quick_actions_grid.dart';
import 'package:smart_campus/features/home/presentation/widgets/recent_announcements_section.dart';
import 'package:smart_campus/features/home/presentation/widgets/upcoming_events_section.dart';
import 'package:smart_campus/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:smart_campus/features/timetable/presentation/bloc/timetable_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'SmartCampus',
        rightIcon: const Icon(Icons.notifications_outlined),
        showBadge: true,
        onRight: () {},
      ),
      body: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      buildWhen: (p, c) => p.runtimeType != c.runtimeType,
      builder: (context, conn) {
        final isOffline = conn is DisconnectedState;
        final glow = Theme.of(context).extension<AppGlowTheme>()!;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: isOffline
                ? glow.ambientTopGradientOffline
                : glow.ambientTopGradient,
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isOffline ? 0.90 : 1.0,
            child: const CustomScrollView(
              physics: BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(child: OfflineBanner()),
                _HomeStateSliver(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeStateSliver extends StatelessWidget {
  const _HomeStateSliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
      builder: (context, ann) {
        return BlocBuilder<TimetableBloc, TimetableState>(
          builder: (context, table) {
            final isLoading = ann is AnnouncementsInitial ||
                ann is AnnouncementsLoading ||
                table is TimetableInitial ||
                table is TimetableLoading;
            if (isLoading) return const HomeLoadingSkeleton();

            final annEmpty =
                ann is AnnouncementsLoaded && ann.announcements.isEmpty;
            final tableEmpty =
                table is TimetableLoaded && table.tasks.isEmpty;
            if (annEmpty && tableEmpty) return const HomeNewUserEmpty();

            return const _HomePopulatedSliver();
          },
        );
      },
    );
  }
}

class _HomePopulatedSliver extends StatelessWidget {
  const _HomePopulatedSliver();

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
          const GreetingHeader(),
          SizedBox(height: AppSpacing.sectionGap.h),
          NextClassCard(onTap: () {}),
          SizedBox(height: AppSpacing.sectionGap.h),
          QuickActionsGrid(onAction: (_) {}),
          SizedBox(height: AppSpacing.sectionGap.h),
          const RecentAnnouncementsSection(),
          SizedBox(height: AppSpacing.sectionGap.h),
          const UpcomingEventsSection(),
        ],
      ),
    );
  }
}
