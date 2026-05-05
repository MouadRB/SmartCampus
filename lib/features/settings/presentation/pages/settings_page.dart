import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/presentation/widgets/app_top_bar.dart';
import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_campus/features/auth/presentation/bloc/auth_event.dart';
import 'package:smart_campus/features/auth/presentation/bloc/auth_state.dart';

/// Minimal settings tab. Today it just shows the signed-in user's profile
/// summary and a Logout button — enough to exercise the auth flow end to
/// end. Future settings (theme, notifications, language) will land here.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Settings'),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) return const SizedBox.shrink();
          final glow = Theme.of(context).extension<AppGlowTheme>()!;
          final user = state.user;
          return Padding(
            padding: EdgeInsets.all(AppSpacing.pagePadding.w),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.paddingCard.r),
                  decoration: glow.cardDecoration,
                  child: Row(
                    children: [
                      Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          color: AppColors.accentSubtle,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: AppColors.accent,
                          size: 22.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name.isEmpty ? 'Student' : user.name,
                              style: AppTextStyles.bodyPrimary
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              user.email,
                              style: AppTextStyles.bodySecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.sectionGap.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthLogoutRequested()),
                    icon: Icon(Icons.logout, size: 18.r),
                    label: Text(
                      'Log out',
                      style: AppTextStyles.bodyPrimary.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.error,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusCard.r),
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
