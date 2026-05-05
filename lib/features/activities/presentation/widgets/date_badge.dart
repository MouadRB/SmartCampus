import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

/// Three-line date pill ("THU / 24 / Apr") shown on the leading edge of an
/// [ActivityCard]. The day-of-month line uses the accent colour for
/// punctuation per the design system rule that yellow == high-contrast.
class DateBadge extends StatelessWidget {
  const DateBadge({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('EEE').format(date).toUpperCase(),
            style: AppTextStyles.eyebrow,
          ),
          SizedBox(height: 2.h),
          Text(
            DateFormat('d').format(date),
            style: AppTextStyles.countdown,
          ),
          SizedBox(height: 2.h),
          Text(
            DateFormat('MMM').format(date),
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }
}
