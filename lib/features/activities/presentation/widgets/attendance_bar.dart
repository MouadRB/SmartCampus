import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

/// Attendance progress bar shown on the Details page. Yellow fill with a
/// small ratio label on the trailing edge.
class AttendanceBar extends StatelessWidget {
  const AttendanceBar({
    super.key,
    required this.attendance,
    required this.capacity,
  });

  final int attendance;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final ratio = capacity == 0
        ? 0.0
        : (attendance / capacity).clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Attendance', style: AppTextStyles.bodySecondary),
            Text(
              capacity == 0 ? '$attendance' : '$attendance / $capacity',
              style: AppTextStyles.bodySecondary
                  .copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 6.h,
            child: Stack(
              children: [
                Container(color: AppColors.border),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(color: AppColors.accent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
