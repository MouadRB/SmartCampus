import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

/// Skeleton loading block — ports the React [Skeleton] from shared.jsx.
///
/// Spec: bg-zinc-800/70 · animate-pulse · rounded-lg.
///
/// Renders a pulsing shimmer block that occupies the same structural space
/// as the content it replaces, maintaining layout fidelity during loading.
/// The pulse cycles between zinc-800 and zinc-700 at 1 second intervals.
///
/// Usage:
/// ```dart
/// SkeletonBlock(height: 88, radius: AppSpacing.radiusCard) // next-class card
/// SkeletonBlock(width: 140, height: 24)                    // text line
/// ```
class SkeletonBlock extends StatefulWidget {
  const SkeletonBlock({
    super.key,
    this.width,
    this.height = 16,
    this.radius,
  });

  final double? width;

  /// Height in logical pixels (will be scaled by ScreenUtil inside build).
  final double height;

  /// Border radius in logical pixels. Defaults to [AppSpacing.radiusIcon] (8).
  final double? radius;

  @override
  State<SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<SkeletonBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _color;

  // zinc-800/70 → zinc-700 pulse — matches Tailwind animate-pulse effect.
  static final _colorDark  = AppColors.border.withValues(alpha: 0.70);
  static final _colorLight = AppColors.borderLight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _color = ColorTween(begin: _colorDark, end: _colorLight).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (context, _) => Container(
        width: widget.width != null ? widget.width!.w : null,
        height: widget.height.h,
        decoration: BoxDecoration(
          color: _color.value,
          borderRadius: BorderRadius.circular(
            (widget.radius ?? AppSpacing.radiusIcon).r,
          ),
        ),
      ),
    );
  }
}
