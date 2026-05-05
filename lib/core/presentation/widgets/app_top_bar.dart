import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

/// Top App Bar — ports the React [TopAppBar] component from shared.jsx.
///
/// Spec: h-14 (56 px) · bg-[#050505]/80 · backdrop-blur-md ·
///       border-b border-zinc-800/50 · centered title · 40-px icon slots.
///
/// Implements [PreferredSizeWidget] so it can be used as [Scaffold.appBar]
/// while also being usable as a plain widget inside a [Column].
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.leftIcon,
    this.onLeft,
    this.rightIcon,
    this.onRight,
    this.extraRightIcon,
    this.onExtraRight,
    this.showBadge = false,
  });

  final String title;

  /// Widget rendered in the 40-px left slot (typically a back arrow).
  final Widget? leftIcon;
  final VoidCallback? onLeft;

  /// Widget rendered in the 40-px right slot (typically a bell icon).
  final Widget? rightIcon;
  final VoidCallback? onRight;

  /// Optional second right-side icon, rendered to the LEFT of [rightIcon].
  /// Used by the dashboard for the "Load Mocks" affordance.
  final Widget? extraRightIcon;
  final VoidCallback? onExtraRight;

  /// When true, renders the 8-px neon-yellow notification dot with glow
  /// in the top-right corner of the right icon slot.
  final bool showBadge;

  /// Raw logical-pixel height — intentionally does NOT use ScreenUtil
  /// because [preferredSize] is called before the widget tree is built.
  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>();

    // Auto back-button: when no leftIcon is explicitly provided and the
    // navigator has a previous route to return to, inject a back arrow so
    // every sub-page gets correct navigation without manual wiring.
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final resolvedLeftIcon =
        leftIcon ?? (canPop ? const Icon(Icons.arrow_back) : null);
    final resolvedOnLeft =
        onLeft ?? (canPop ? () => Navigator.of(context).pop() : null);

    return ClipRect(
      // ClipRect is required for BackdropFilter to limit its blur region
      // to the bar area and not bleed into the content below.
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: AppSpacing.appBarHeight.h,
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.80),
            border: Border(
              bottom: BorderSide(
                color: AppColors.border.withValues(alpha: 0.50),
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                // ── Left slot (40 dp wide) ──────────────────────────────
                SizedBox(
                  width: 40.w,
                  child: resolvedLeftIcon != null
                      ? IconButton(
                          onPressed: resolvedOnLeft,
                          icon: resolvedLeftIcon,
                          iconSize: 24.r,
                          color: AppColors.textSecondary,
                          padding: EdgeInsets.all(6.r),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        )
                      : const SizedBox.shrink(),
                ),

                // ── Centered title ──────────────────────────────────────
                Expanded(
                  child: Center(
                    child: Text(title, style: AppTextStyles.appBarTitle),
                  ),
                ),

                // ── Optional extra right slot (40 dp wide) ──────────────
                if (extraRightIcon != null)
                  SizedBox(
                    width: 40.w,
                    child: IconButton(
                      onPressed: onExtraRight,
                      icon: extraRightIcon!,
                      iconSize: 22.r,
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.all(6.r),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  ),

                // ── Right slot (40 dp wide) with optional badge ─────────
                SizedBox(
                  width: 40.w,
                  child: rightIcon != null
                      ? Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: onRight,
                              icon: rightIcon!,
                              iconSize: 24.r,
                              color: AppColors.textSecondary,
                              padding: EdgeInsets.all(6.r),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                            if (showBadge)
                              Positioned(
                                top: 8.r,
                                right: 6.r,
                                child: Container(
                                  width: 8.r,
                                  height: 8.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accent,
                                    boxShadow: glow?.accentGlowSm ?? const [
                                      BoxShadow(
                                        color: AppColors.accentGlow050,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
