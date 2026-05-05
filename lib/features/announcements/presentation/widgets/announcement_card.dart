import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';
import 'package:smart_campus/features/announcements/presentation/widgets/announcement_category.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  final Announcement announcement;
  final VoidCallback onTap;

  // Pseudo-author derived from id since /posts has no author field.
  String get _author {
    switch (announcement.id % 4) {
      case 0:
        return 'Campus Admin';
      case 1:
        return 'Registrar Office';
      case 2:
        return 'Facilities Mgmt';
      default:
        return 'Events Team';
    }
  }

  // Pseudo-timestamp derived from id (newer = higher id, mins/hours/days).
  String get _timeAgo {
    final h = (announcement.id % 47);
    if (h < 1) return '10 min ago';
    if (h < 24) return '${h}h ago';
    return '${(h ~/ 24)}d ago';
  }

  // Most cards have an attachment in the design — heuristic mirrors that.
  bool get _hasAttachment => announcement.id % 4 < 3;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;
    final category = AnnouncementCategory.fromAnnouncement(announcement);
    final colors = category.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
        child: DecoratedBox(
          decoration: glow.cardDecoration,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3.w, color: colors.accent),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CardHeader(
                          category: category,
                          colors: colors,
                          timeAgo: _timeAgo,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          announcement.title,
                          style: AppTextStyles.bodyPrimary.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          announcement.body,
                          style: AppTextStyles.bodySecondary.copyWith(
                            height: 1.45,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10.h),
                        _CardFooter(
                          author: _author,
                          hasAttachment: _hasAttachment,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.category,
    required this.colors,
    required this.timeAgo,
  });

  final AnnouncementCategory category;
  final CategoryColors colors;
  final String timeAgo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: colors.chipBg,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            category.label,
            style: AppTextStyles.navLabel.copyWith(color: colors.chipText),
          ),
        ),
        const Spacer(),
        Text(
          timeAgo,
          style: AppTextStyles.micro.copyWith(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.author, required this.hasAttachment});

  final String author;
  final bool hasAttachment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(initial: author.isNotEmpty ? author.characters.first : '?'),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            author,
            style: AppTextStyles.micro.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasAttachment) ...[
          Icon(
            Icons.attach_file_rounded,
            size: 12.r,
            color: AppColors.textTertiary,
          ),
          SizedBox(width: 4.w),
          Text(
            '1 file',
            style: AppTextStyles.micro.copyWith(fontWeight: FontWeight.w400),
          ),
        ],
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.r,
      height: 22.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        initial.toUpperCase(),
        style: AppTextStyles.micro.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
