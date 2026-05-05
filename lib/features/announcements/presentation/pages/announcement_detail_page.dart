import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/presentation/widgets/app_top_bar.dart';
import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';

/// Announcement Detail Page — editorial expansion of a single [Announcement].
///
/// Receives the pure Domain [Announcement] entity via its constructor.
/// No BLoC is involved: the data is fully materialised at the call site.
///
/// Design language: "editorial expansion of the existing cards."
/// - A 2 px category-accented horizontal bar anchors the top of the content.
/// - The tag chip uses the same colour tokens as the feed cards, so the
///   category identity is continuous across both surfaces.
/// - The title is scaled up (22 sp, bold) for comfortable headline reading.
/// - The body uses 15 sp at 1.70 line-height — deliberately looser than
///   the card excerpts to reward the user for tapping through.
///
/// Clean Architecture note: this page sits in the Presentation layer and
/// depends only on [Announcement] (Domain entity). It never imports from
/// data/ and carries no repository or datasource references.
class AnnouncementDetailPage extends StatelessWidget {
  const AnnouncementDetailPage({super.key, required this.announcement});

  final Announcement announcement;

  // ── Category derivation (same heuristic as the feed cards) ───────────────

  String get _tag {
    switch (announcement.id % 3) {
      case 0:  return 'Urgent';
      case 1:  return 'Academic';
      default: return 'General';
    }
  }

  /// Returns (tagBg, tagText, accentBar) colour triple for the category.
  (Color, Color, Color) get _categoryColors {
    switch (_tag) {
      case 'Urgent':
        return (AppColors.errorBg, AppColors.error, AppColors.error);
      case 'Academic':
        return (AppColors.accentSubtle, AppColors.accent, AppColors.accent);
      default:
        return (AppColors.border, AppColors.textSecondary, AppColors.textSecondary);
    }
  }

  String get _pseudoTime {
    final h = (announcement.id % 23) + 1;
    if (h == 1) return '1h ago';
    if (h < 24) return '${h}h ago';
    return '${announcement.id % 6 + 1}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final (tagBg, tagText, accentBar) = _categoryColors;
    final glow = Theme.of(context).extension<AppGlowTheme>();

    return Scaffold(
      backgroundColor: AppColors.background,
      // AppTopBar auto-detects canPop → back arrow appears without wiring.
      appBar: const AppTopBar(title: 'Announcement'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Category accent bar ──────────────────────────────────────
            // Full-width 2 px horizontal line in the category colour.
            // The editorial touchpoint that ties the detail view to its card.
            Container(
              height: 2,
              width: double.infinity,
              color: accentBar.withValues(alpha: 0.70),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pagePadding.w,
                20.h,
                AppSpacing.pagePadding.w,
                40.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tag chip ───────────────────────────────────────────
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: tagBg,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      _tag,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: tagText,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Editorial headline ─────────────────────────────────
                  Text(
                    announcement.title,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Metadata row ───────────────────────────────────────
                  Row(
                    children: [
                      // Small accent dot matching the category colour
                      Container(
                        width: 5.r,
                        height: 5.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentBar.withValues(alpha: 0.70),
                          boxShadow: _tag != 'General'
                              ? glow?.accentGlowSm
                              : null,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Staff · $_pseudoTime',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 22.h),

                  // ── Divider ────────────────────────────────────────────
                  Container(
                    height: 0.5,
                    width: double.infinity,
                    color: AppColors.border.withValues(alpha: 0.50),
                  ),

                  SizedBox(height: 24.h),

                  // ── Body text ──────────────────────────────────────────
                  // 15 sp / 1.70 line-height — deliberately more generous
                  // than card excerpts to reward the tap-through.
                  Text(
                    announcement.body,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.70,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // ── Share / action footer ──────────────────────────────
                  // Visually complete the page without requiring a real
                  // implementation — the button is inert until wired in
                  // a future sprint.
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 20.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusCard.r),
                      border: Border(
                        top:    BorderSide(color: AppColors.border),
                        right:  BorderSide(color: AppColors.border),
                        bottom: BorderSide(color: AppColors.border),
                        left:   BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share_outlined,
                          size: 16.r,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Share announcement',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
