import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

/// Two-up segmented pill ([List] | [Calendar]) shown directly under the
/// app bar on the Activities page. The active segment fills with the
/// accent colour; the inactive segment stays on the surface tone.
enum ActivitiesView { list, calendar }

class ViewToggle extends StatelessWidget {
  const ViewToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ActivitiesView value;
  final ValueChanged<ActivitiesView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              icon: Icons.more_horiz,
              label: 'List',
              active: value == ActivitiesView.list,
              onTap: () => onChanged(ActivitiesView.list),
            ),
          ),
          Expanded(
            child: _Segment(
              icon: Icons.calendar_today_outlined,
              label: 'Calendar',
              active: value == ActivitiesView.calendar,
              onTap: () => onChanged(ActivitiesView.calendar),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.background : AppColors.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.r, color: fg),
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppTextStyles.bodyPrimary.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
