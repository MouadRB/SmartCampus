import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key, this.onAction});

  final void Function(String id)? onAction;

  static const _items = <_ActionItem>[
    _ActionItem(
      id: 'timetable',
      label: 'Timetable',
      icon: Icons.access_time_rounded,
      iconColor: AppColors.accent,
      bgColor: AppColors.accentSubtle,
    ),
    _ActionItem(
      id: 'map',
      label: 'Campus Map',
      icon: Icons.map_outlined,
      iconColor: AppColors.sky,
      bgColor: AppColors.skyBg,
    ),
    _ActionItem(
      id: 'library',
      label: 'Library',
      icon: Icons.menu_book_outlined,
      iconColor: AppColors.purple,
      bgColor: AppColors.purpleBg,
    ),
    _ActionItem(
      id: 'dining',
      label: 'Dining',
      icon: Icons.local_cafe_outlined,
      iconColor: AppColors.orange,
      bgColor: AppColors.orangeBg,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.sectionHeader),
        SizedBox(height: 12.h),
        GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 12.w,
          crossAxisSpacing: 12.w,
          childAspectRatio: 74 / 80,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _items
              .map(
                (item) => _ActionButton(
                  item: item,
                  onTap: () => onAction?.call(item.id),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({required this.item, required this.onTap});

  final _ActionItem item;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
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
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: glow.cardDecoration,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: widget.item.bgColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusIcon.r),
                ),
                child: Icon(
                  widget.item.icon,
                  size: 18.r,
                  color: widget.item.iconColor,
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  widget.item.label,
                  style: AppTextStyles.navLabel.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
