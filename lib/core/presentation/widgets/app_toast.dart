import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

/// In-app Toast notification — ports the React [Toast] from shared.jsx.
///
/// Spec: absolute · top-[88px] · left-3 right-3 · rounded-2xl ·
///       bg-zinc-900/95 · backdrop-blur (visual approximation via elevation) ·
///       border border-zinc-700/50 · shadow-[0_0_24px_rgba(253,224,71,0.12)] ·
///       slideDown 0.25 s ease + auto-dismiss at 3.5 s.
///
/// Renders as a positioned overlay. The parent must use a [Stack] and
/// position this widget at the correct offset (88 px from top = AppBar + banner).
///
/// ```dart
/// // Show from a parent Stack:
/// if (_toast != null)
///   Positioned(
///     top: (AppSpacing.appBarHeight + 8).h,
///     left: 12.w, right: 12.w,
///     child: AppToast(
///       message: _toast!.message,
///       iconData: _toast!.icon,
///       onDismiss: () => setState(() => _toast = null),
///     ),
///   ),
/// ```
class AppToast extends StatefulWidget {
  const AppToast({
    super.key,
    required this.message,
    this.iconData,
    required this.onDismiss,
  });

  final String message;

  /// Icon displayed in the left accent circle. Defaults to the bell icon.
  final IconData? iconData;
  final VoidCallback onDismiss;

  @override
  State<AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<AppToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();

    // opacity: 0 → 1
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // translateY: -8px → 0 (slideDown from shared.jsx keyframe)
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Auto-dismiss after 3.5 s (matches React setTimeout 3500).
    Future.delayed(const Duration(milliseconds: 3500), _safeDismiss);
  }

  void _safeDismiss() {
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>();

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            // zinc-900/95 — near-opaque for legibility
            color: const Color(0xF2171717),
            borderRadius: BorderRadius.circular(AppSpacing.radiusToast.r),
            border: Border(
              top:    BorderSide(color: AppColors.borderElevated),
              right:  BorderSide(color: AppColors.borderElevated),
              bottom: BorderSide(color: AppColors.borderElevated),
              left:   BorderSide(color: AppColors.borderElevated),
            ),
            // shadow-[0_0_24px_rgba(253,224,71,0.12)]
            boxShadow: glow?.accentGlowLg ?? const [
              BoxShadow(color: AppColors.accentGlow012, blurRadius: 24),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Accent icon circle ──────────────────────────────────────
              Container(
                width: 32.r,
                height: 32.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentSubtle, // yellow-300/10
                ),
                child: Icon(
                  widget.iconData ?? Icons.notifications_outlined,
                  size: 16.r,
                  color: AppColors.accent,
                ),
              ),

              SizedBox(width: 12.w),

              // ── Message ─────────────────────────────────────────────────
              Expanded(
                child: Text(
                  widget.message,
                  style: AppTextStyles.bodyPrimary.copyWith(
                    height: 1.3, // leading-snug
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // ── Dismiss button ──────────────────────────────────────────
              GestureDetector(
                onTap: widget.onDismiss,
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(
                    Icons.close,
                    size: 14.r,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
