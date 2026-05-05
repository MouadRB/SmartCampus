import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/connectivity/connectivity_bloc.dart';
import 'package:smart_campus/core/connectivity/connectivity_state.dart';
import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_campus/features/auth/presentation/bloc/auth_state.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _dateLabel {
    final now = DateTime.now();
    return '${_days[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      buildWhen: (p, c) => p.runtimeType != c.runtimeType,
      builder: (context, state) {
        final isOffline = state is DisconnectedState;

        return BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) =>
              p is! Authenticated || c is! Authenticated ||
              (p).user.name != (c).user.name,
          builder: (context, authState) {
            final name = _firstName(authState);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_dateLabel, style: AppTextStyles.greetingDate),
                SizedBox(height: 2.h),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.w,
                  runSpacing: 4.h,
                  children: [
                    Text('$_greeting, $name',
                        style: AppTextStyles.greetingName),
                    if (isOffline) const _CachedPill(),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _firstName(AuthState state) {
    if (state is! Authenticated) return 'Student';
    final raw = state.user.name.trim();
    if (raw.isEmpty) return 'Student';
    final first = raw.split(RegExp(r'\s+')).first;
    return first[0].toUpperCase() + first.substring(1);
  }
}

class _CachedPill extends StatelessWidget {
  const _CachedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.offlineBg,
        border: Border.all(color: AppColors.offlineBorder),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        'Cached',
        style: AppTextStyles.navLabel.copyWith(color: AppColors.offlineText),
      ),
    );
  }
}
