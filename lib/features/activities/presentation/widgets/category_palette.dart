import 'package:flutter/material.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

/// Foreground/background pair drawn from [AppColors] for a given activity
/// category. Centralised here so widgets never hardcode hex values and the
/// taxonomy can be promoted to an enum without scattering changes.
class CategoryPalette {
  const CategoryPalette({required this.foreground, required this.background});

  final Color foreground;
  final Color background;

  static CategoryPalette of(String category) {
    switch (category.toLowerCase()) {
      case 'career':
        return const CategoryPalette(
          foreground: AppColors.sky,
          background: AppColors.skyBg,
        );
      case 'academic':
      case 'lecture':
        return const CategoryPalette(
          foreground: AppColors.accent,
          background: AppColors.accentSubtle,
        );
      case 'community':
        return const CategoryPalette(
          foreground: AppColors.green,
          background: AppColors.greenBg,
        );
      case 'workshop':
        return const CategoryPalette(
          foreground: AppColors.purple,
          background: AppColors.purpleBg,
        );
      case 'social':
        return const CategoryPalette(
          foreground: AppColors.pink,
          background: AppColors.pinkBg,
        );
      case 'club':
        return const CategoryPalette(
          foreground: AppColors.orange,
          background: AppColors.orangeBg,
        );
      default:
        return const CategoryPalette(
          foreground: AppColors.textSecondary,
          background: AppColors.surface,
        );
    }
  }
}
