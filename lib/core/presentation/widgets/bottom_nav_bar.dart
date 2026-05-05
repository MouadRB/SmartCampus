import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';

/// The four primary navigation destinations.
enum NavTab { home, announcements, events, settings }

/// Bottom Navigation Bar — ports the React [BottomNav] from shared.jsx.
///
/// Spec: h-16 (64 px) · bg-[#0a0a0a] · border-t border-zinc-800/50 ·
///       4 equally-spaced tabs · active: yellow-300 icon + glow + bold label ·
///       inactive: zinc-500.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabChange,
    this.showAnnouncementDot = false,
  });

  final NavTab activeTab;
  final ValueChanged<NavTab> onTabChange;

  /// When true, renders the yellow dot on the Alerts tab (when not active)
  /// to signal unread announcements.
  final bool showAnnouncementDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.navHeight.h,
      decoration: BoxDecoration(
        color: AppColors.navBar,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.50),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: NavTab.values
              .map(
                (tab) => _NavItem(
                  tab: tab,
                  isActive: activeTab == tab,
                  onTap: () => onTabChange(tab),
                  showDot: tab == NavTab.announcements &&
                      showAnnouncementDot &&
                      activeTab != NavTab.announcements,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ── Private nav item ──────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
    this.showDot = false,
  });

  final NavTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final bool showDot;

  static const Map<NavTab, (IconData, String)> _config = {
    NavTab.home:          (Icons.home_outlined,           'Home'),
    NavTab.announcements: (Icons.notifications_outlined,  'Alerts'),
    NavTab.events:        (Icons.calendar_today_outlined,  'Events'),
    NavTab.settings:      (Icons.settings_outlined,       'Settings'),
  };

  @override
  Widget build(BuildContext context) {
    final (iconData, label) = _config[tab]!;
    final glow = Theme.of(context).extension<AppGlowTheme>();

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon with conditional neon glow ─────────────────────────
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Blurred duplicate creates the drop-shadow glow effect.
                  // Mirrors CSS: drop-shadow(0 0 8px rgba(253,224,71,0.5))
                  if (isActive)
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                        tileMode: TileMode.decal,
                      ),
                      child: Icon(
                        iconData,
                        size: 22.r,
                        color: AppColors.accent.withValues(alpha: 0.55),
                      ),
                    ),
                  // Crisp icon on top
                  Icon(
                    iconData,
                    size: 22.r,
                    color:
                        isActive ? AppColors.accent : AppColors.textTertiary,
                  ),
                  // Unread dot (yellow-300 + glow)
                  if (showDot)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 7.r,
                        height: 7.r,
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
              ),

              SizedBox(height: 2.h),

              // ── Label ────────────────────────────────────────────────────
              Text(
                label,
                style: AppTextStyles.navLabel.copyWith(
                  color: isActive ? AppColors.accent : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
