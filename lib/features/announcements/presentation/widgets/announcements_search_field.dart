import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

class AnnouncementsSearchField extends StatelessWidget {
  const AnnouncementsSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 18.r,
                  color: AppColors.textTertiary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    cursorColor: AppColors.accent,
                    style: AppTextStyles.bodyPrimary,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      hintText: 'Search announcements...',
                      hintStyle: AppTextStyles.bodyPrimary.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10.w),
        _FilterIconButton(onTap: onFilterTap),
      ],
    );
  }
}

class _FilterIconButton extends StatelessWidget {
  const _FilterIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44.r,
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 18.r,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
