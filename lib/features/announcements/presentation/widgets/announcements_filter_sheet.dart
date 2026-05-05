import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/announcements/presentation/widgets/announcement_category.dart';

class FilterResult {
  const FilterResult({required this.category, required this.sortOrder});

  final AnnouncementCategory? category;
  final SortOrder sortOrder;
}

Future<FilterResult?> showAnnouncementsFilterSheet(
  BuildContext context, {
  required AnnouncementCategory? initialCategory,
  required SortOrder initialSort,
}) {
  return showModalBottomSheet<FilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) => _AnnouncementsFilterSheet(
      initialCategory: initialCategory,
      initialSort: initialSort,
    ),
  );
}

class _AnnouncementsFilterSheet extends StatefulWidget {
  const _AnnouncementsFilterSheet({
    required this.initialCategory,
    required this.initialSort,
  });

  final AnnouncementCategory? initialCategory;
  final SortOrder initialSort;

  @override
  State<_AnnouncementsFilterSheet> createState() =>
      _AnnouncementsFilterSheetState();
}

class _AnnouncementsFilterSheetState extends State<_AnnouncementsFilterSheet> {
  late AnnouncementCategory? _category = widget.initialCategory;
  late SortOrder _sort = widget.initialSort;

  void _apply() {
    Navigator.of(context).pop(
      FilterResult(category: _category, sortOrder: _sort),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pagePadding.w,
          12.h,
          AppSpacing.pagePadding.w,
          AppSpacing.paddingCard.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filter & Sort',
                    style: AppTextStyles.appBarTitle,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20.r,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text('CATEGORY', style: AppTextStyles.eyebrow),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: AnnouncementCategory.values.map((category) {
                return _SheetPill(
                  label: category.label,
                  isActive: _category == category,
                  onTap: () => setState(
                    () =>
                        _category = _category == category ? null : category,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),
            Text('SORT ORDER', style: AppTextStyles.eyebrow),
            SizedBox(height: 12.h),
            Row(
              children: [
                for (var i = 0; i < SortOrder.values.length; i++) ...[
                  Expanded(
                    child: _SortOption(
                      label: SortOrder.values[i].label,
                      isActive: _sort == SortOrder.values[i],
                      onTap: () =>
                          setState(() => _sort = SortOrder.values[i]),
                    ),
                  ),
                  if (i < SortOrder.values.length - 1) SizedBox(width: 10.w),
                ],
              ],
            ),
            SizedBox(height: 20.h),
            _ApplyButton(onTap: _apply),
          ],
        ),
      ),
    );
  }
}

class _SheetPill extends StatelessWidget {
  const _SheetPill({
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.background,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.border,
          ),
          boxShadow: isActive ? glow.accentGlowSm : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySecondary.copyWith(
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.background : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
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
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.border,
          ),
          boxShadow: isActive ? glow.accentGlowSm : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyPrimary.copyWith(
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.background : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ApplyButton extends StatefulWidget {
  const _ApplyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<_ApplyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;

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
          height: 48.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
            boxShadow: glow.accentGlowLg,
          ),
          child: Text(
            'Apply Filters',
            style: AppTextStyles.bodyPrimary.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.background,
            ),
          ),
        ),
      ),
    );
  }
}
