import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/announcements/presentation/widgets/announcement_category.dart';

class AnnouncementsCategoryChips extends StatelessWidget {
  const AnnouncementsCategoryChips({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  /// Null = "All" pill is active.
  final AnnouncementCategory? selected;

  /// Called with the new selection. Pass `null` for "All".
  final ValueChanged<AnnouncementCategory?> onSelect;

  static const _displayOrder = <AnnouncementCategory>[
    AnnouncementCategory.academic,
    AnnouncementCategory.urgent,
    AnnouncementCategory.general,
    AnnouncementCategory.events,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
        itemCount: _displayOrder.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'All',
              isActive: selected == null,
              onTap: () => onSelect(null),
            );
          }
          final category = _displayOrder[index - 1];
          return _CategoryChip(
            label: category.label,
            isActive: selected == category,
            onTap: () =>
                onSelect(selected == category ? null : category),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.border,
          ),
          boxShadow: isActive ? glow.accentGlowSm : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.navLabel.copyWith(
            fontSize: 12.sp,
            color: isActive ? AppColors.background : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
