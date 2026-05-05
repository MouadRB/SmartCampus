import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/connectivity/connectivity_bloc.dart';
import 'package:smart_campus/core/connectivity/connectivity_state.dart';
import 'package:smart_campus/core/theme/app_theme.dart';

/// Offline Banner — ports the React [OfflineBanner] from shared.jsx.
///
/// Spec: py-2 · bg-amber-500/15 · border-b border-amber-500/30 ·
///       WifiOff icon (11 px) + "No internet · Showing cached data" (text-xs) ·
///       text-amber-400 · non-dismissible.
///
/// Listens to [ConnectivityBloc] and renders only when [DisconnectedState]
/// is active. Collapses to [SizedBox.shrink] when online so it leaves
/// no layout gap.
///
/// Designed to sit immediately below [AppTopBar] inside a [Column] body,
/// or to be injected via an [Overlay] / top-level [Stack] for global coverage.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      // Rebuild only when the connectivity class changes — not on every
      // identical state re-emission (Equatable handles the diffing).
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        if (state is! DisconnectedState) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: const BoxDecoration(
            color: AppColors.offlineBg,
            border: Border(
              bottom: BorderSide(color: AppColors.offlineBorder),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 11.r,
                color: AppColors.offlineText,
              ),
              SizedBox(width: 6.w),
              Text(
                'No internet · Showing cached data',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.offlineText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
