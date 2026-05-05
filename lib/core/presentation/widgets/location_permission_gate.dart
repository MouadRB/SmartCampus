import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_type.dart';
import 'package:smart_campus/features/permissions/presentation/bloc/permissions_bloc.dart';
import 'package:smart_campus/features/permissions/presentation/bloc/permissions_event.dart';
import 'package:smart_campus/features/permissions/presentation/bloc/permissions_state.dart';

/// Renders [child] only when the Location permission is granted. Drives
/// FR-PERM-03's three-state flow:
///   * State A: dispatches [CheckPermissionRequested] on first build.
///   * State B (denied): renders a rationale + "Grant access" button that
///     dispatches [RequestPermissionRequested].
///   * State C (permanently denied): renders an "Open Settings" button that
///     dispatches [OpenSettingsRequested].
///
/// Reusable: pass any [child] (e.g., the future Campus Map screen). The
/// widget never calls `permission_handler` directly — UI dispatches events
/// only, in keeping with the rule that hardware access flows through BLoCs.
class LocationPermissionGate extends StatefulWidget {
  const LocationPermissionGate({
    super.key,
    required this.child,
    this.rationaleMessage =
        'SmartCampus needs your location to show your position relative to '
            'campus points of interest.',
  });

  final Widget child;
  final String rationaleMessage;

  @override
  State<LocationPermissionGate> createState() => _LocationPermissionGateState();
}

class _LocationPermissionGateState extends State<LocationPermissionGate> {
  @override
  void initState() {
    super.initState();
    // Defer the first dispatch so context.read() can find the bloc above.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PermissionsBloc>().add(
            const CheckPermissionRequested(PermissionType.location),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionsBloc, PermissionsState>(
      builder: (context, state) {
        if (state is PermissionGranted &&
            state.type == PermissionType.location) {
          return widget.child;
        }
        if (state is PermissionPermanentlyDenied &&
            state.type == PermissionType.location) {
          return _SettingsRedirectView(message: state.message);
        }
        if (state is PermissionDenied &&
            state.type == PermissionType.location) {
          return _RationaleView(message: widget.rationaleMessage);
        }
        if (state is PermissionsError) {
          return _RationaleView(
            message: state.message,
            ctaLabel: 'Try again',
          );
        }
        // Initial / Loading / state belonging to a different permission type.
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _RationaleView extends StatelessWidget {
  const _RationaleView({
    required this.message,
    this.ctaLabel = 'Grant access',
  });

  final String message;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return _GateScaffold(
      icon: Icons.location_on_outlined,
      title: 'Location permission needed',
      message: message,
      ctaLabel: ctaLabel,
      onCta: () => context.read<PermissionsBloc>().add(
            const RequestPermissionRequested(PermissionType.location),
          ),
    );
  }
}

class _SettingsRedirectView extends StatelessWidget {
  const _SettingsRedirectView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _GateScaffold(
      icon: Icons.settings_outlined,
      title: 'Open system settings',
      message:
          '$message\n\nEnable Location for SmartCampus in your device settings, then return to the app.',
      ctaLabel: 'Open Settings',
      onCta: () => context.read<PermissionsBloc>().add(
            const OpenSettingsRequested(),
          ),
    );
  }
}

class _GateScaffold extends StatelessWidget {
  const _GateScaffold({
    required this.icon,
    required this.title,
    required this.message,
    required this.ctaLabel,
    required this.onCta,
  });

  final IconData icon;
  final String title;
  final String message;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding.w,
        vertical: AppSpacing.paddingCard.h,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentSubtle,
                boxShadow: glow.accentGlowSm,
              ),
              child: Icon(icon, size: 28.r, color: AppColors.accent),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: AppTextStyles.appBarTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: onCta,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusCard.r),
                  boxShadow: glow.accentGlowLg,
                ),
                child: Text(
                  ctaLabel,
                  style: AppTextStyles.sectionHeader.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
