import 'package:flutter/material.dart';

import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';

enum AnnouncementCategory {
  urgent('Urgent'),
  academic('Academic'),
  general('General'),
  events('Events');

  const AnnouncementCategory(this.label);

  final String label;

  static AnnouncementCategory fromAnnouncement(Announcement a) {
    switch (a.id % 4) {
      case 0:
        return AnnouncementCategory.urgent;
      case 1:
        return AnnouncementCategory.academic;
      case 2:
        return AnnouncementCategory.general;
      default:
        return AnnouncementCategory.events;
    }
  }

  CategoryColors get colors {
    switch (this) {
      case AnnouncementCategory.urgent:
        return const CategoryColors(
          chipBg: AppColors.errorBg,
          chipText: AppColors.error,
          accent: AppColors.error,
        );
      case AnnouncementCategory.academic:
        return const CategoryColors(
          chipBg: AppColors.accentSubtle,
          chipText: AppColors.accent,
          accent: AppColors.accent,
        );
      case AnnouncementCategory.general:
        return const CategoryColors(
          chipBg: AppColors.border,
          chipText: AppColors.textSecondary,
          accent: AppColors.textTertiary,
        );
      case AnnouncementCategory.events:
        return const CategoryColors(
          chipBg: AppColors.skyBg,
          chipText: AppColors.sky,
          accent: AppColors.sky,
        );
    }
  }
}

class CategoryColors {
  const CategoryColors({
    required this.chipBg,
    required this.chipText,
    required this.accent,
  });

  final Color chipBg;
  final Color chipText;
  final Color accent;
}

enum SortOrder {
  newestFirst('Newest First'),
  oldestFirst('Oldest First');

  const SortOrder(this.label);

  final String label;
}
