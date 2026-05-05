import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/presentation/widgets/skeleton_block.dart';
import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_state.dart';
import 'package:smart_campus/features/announcements/presentation/pages/announcement_detail_page.dart';
import 'package:smart_campus/features/announcements/presentation/pages/announcements_page.dart';

class RecentAnnouncementsSection extends StatelessWidget {
  const RecentAnnouncementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Announcements',
          onSeeAll: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider<AnnouncementsBloc>.value(
                value: context.read<AnnouncementsBloc>(),
                child: const AnnouncementsPage(),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
          builder: (context, state) {
            if (state is AnnouncementsInitial ||
                state is AnnouncementsLoading) {
              return const _SkeletonRow();
            }
            if (state is AnnouncementsLoaded) {
              final top3 = state.announcements.take(3).toList();
              return top3.isEmpty
                  ? const _EmptyHint()
                  : _CardRow(announcements: top3);
            }
            if (state is AnnouncementsOffline) {
              return const _StatusHint(
                icon: Icons.wifi_off_rounded,
                tone: _StatusTone.offline,
                message: 'Offline · Showing cached announcements',
              );
            }
            if (state is AnnouncementsError) {
              return const _StatusHint(
                icon: Icons.error_outline_rounded,
                tone: _StatusTone.error,
                message: 'Could not load announcements',
              );
            }
            return const _SkeletonRow();
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
        GestureDetector(
          onTap: onSeeAll,
          behavior: HitTestBehavior.opaque,
          child: Text(
            'See All',
            style: AppTextStyles.navLabel.copyWith(color: AppColors.accent),
          ),
        ),
      ],
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: List.generate(3, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i < 2 ? 12.w : 0),
            child: const SkeletonBlock(
              width: 176,
              height: 108,
              radius: AppSpacing.radiusCard,
            ),
          );
        }),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.announcements});

  final List<Announcement> announcements;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(announcements.length, (i) {
          final item = announcements[i];
          return Padding(
            padding: EdgeInsets.only(
              right: i < announcements.length - 1 ? 12.w : 0,
            ),
            child: _AnnouncementCard(announcement: item),
          );
        }),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement});

  final Announcement announcement;

  // TODO(announcement-entity): derive from a Domain `category` field once it
  // exists on Announcement. The entity today only exposes
  // {id, userId, title, body}, so we render a neutral 'General' chip.
  String get _tag => 'General';

  (Color bg, Color text) get _tagStyle =>
      (AppColors.border, AppColors.textSecondary);

  // TODO(announcement-entity): derive from a Domain `isRead` field once it
  // exists. Until then read status cannot be known, so the unread dot is
  // suppressed.
  bool get _isUnread => false;

  // TODO(announcement-entity): format a relative timestamp from a Domain
  // `createdAt` field once it exists. The entity has no timestamp today.
  String get _timeAgo => '—';

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;
    final (tagBg, tagText) = _tagStyle;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AnnouncementDetailPage(announcement: announcement),
        ),
      ),
      child: Container(
        width: 176.w,
        padding: EdgeInsets.all(AppSpacing.paddingCardSm.r),
        decoration: glow.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    _tag,
                    style: AppTextStyles.navLabel.copyWith(color: tagText),
                  ),
                ),
                if (_isUnread)
                  Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                      boxShadow: glow.accentGlowSm,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              announcement.title,
              style: AppTextStyles.bodySecondary.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Text(
              _timeAgo,
              style: AppTextStyles.micro.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StatusTone { offline, error }

class _StatusHint extends StatelessWidget {
  const _StatusHint({
    required this.icon,
    required this.tone,
    required this.message,
  });

  final IconData icon;
  final _StatusTone tone;
  final String message;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (tone) {
      _StatusTone.offline => (
          AppColors.offlineBg,
          AppColors.offlineBorder,
          AppColors.offlineText,
        ),
      _StatusTone.error => (
          AppColors.errorBg,
          AppColors.error.withValues(alpha: 0.30),
          AppColors.error,
        ),
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: fg),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySecondary.copyWith(
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: glow.cardDecoration,
      child: Text(
        'No announcements yet',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySecondary,
      ),
    );
  }
}
