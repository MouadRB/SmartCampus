import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:smart_campus/core/injection/injection_container.dart' as di;
import 'package:smart_campus/core/presentation/widgets/app_top_bar.dart';
import 'package:smart_campus/core/presentation/widgets/location_permission_gate.dart';
import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/location/domain/entities/coordinates.dart';
import 'package:smart_campus/features/location/presentation/bloc/location_bloc.dart';
import 'package:smart_campus/features/location/presentation/bloc/location_event.dart';
import 'package:smart_campus/features/location/presentation/bloc/location_state.dart';

/// Tab 0 → /map push target (README §5.2). The page itself is a dumb
/// composer:
///   1. The route owns a fresh [LocationBloc] via a scoped [BlocProvider].
///      Closing the route cancels its stream subscription (see
///      `LocationBloc.close`).
///   2. The body is wrapped *entirely* in [LocationPermissionGate], so the
///      map is only mounted once the user has granted Location. Denials
///      and permanent denials are handled by the gate, not by this page.
///   3. The inner [_CampusMapView] consumes [LocationBloc] state, plots a
///      blue dot, and animates the camera onto each new fix.
class CampusMapPage extends StatelessWidget {
  const CampusMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationBloc>(
      create: (_) => di.sl<LocationBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppTopBar(title: 'Campus Map'),
        body: const LocationPermissionGate(child: _CampusMapView()),
      ),
    );
  }
}

class _CampusMapView extends StatefulWidget {
  const _CampusMapView();

  @override
  State<_CampusMapView> createState() => _CampusMapViewState();
}

class _CampusMapViewState extends State<_CampusMapView> {
  GoogleMapController? _controller;
  bool _hasCenteredOnce = false;

  // Fallback initial camera target before the first fix arrives. The
  // view animates to the user's actual location as soon as
  // LocationTracking emits.
  static const _fallbackCamera = CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );

  @override
  void initState() {
    super.initState();
    // Subscribe immediately — the gate guarantees permission is granted by
    // the time this widget mounts, so TrackPosition opens the OS stream
    // without needing a re-prompt.
    context.read<LocationBloc>().add(const TrackPosition());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _centerOn(Coordinates coords) {
    final controller = _controller;
    if (controller == null) return;

    final target = CameraPosition(
      target: LatLng(coords.latitude, coords.longitude),
      zoom: 17,
    );

    if (_hasCenteredOnce) {
      controller.animateCamera(CameraUpdate.newCameraPosition(target));
    } else {
      controller.moveCamera(CameraUpdate.newCameraPosition(target));
      _hasCenteredOnce = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationBloc, LocationState>(
      listenWhen: (prev, curr) =>
          curr is LocationTracking || curr is LocationGranted,
      listener: (context, state) {
        if (state is LocationTracking) _centerOn(state.coordinates);
        if (state is LocationGranted) _centerOn(state.coordinates);
      },
      builder: (context, state) {
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _fallbackCamera,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              compassEnabled: true,
              onMapCreated: (controller) {
                _controller = controller;
                // The first fix may have arrived before the controller was
                // ready; re-apply now that we can drive the camera.
                final s = context.read<LocationBloc>().state;
                if (s is LocationTracking) _centerOn(s.coordinates);
                if (s is LocationGranted) _centerOn(s.coordinates);
              },
            ),
            if (state is LocationLoading || state is LocationInitial)
              const _LocatingPill(),
            if (state is LocationError)
              _ErrorBanner(message: state.message),
          ],
        );
      },
    );
  }
}

class _LocatingPill extends StatelessWidget {
  const _LocatingPill();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 12),
          child: Material(
            color: AppColors.navBar,
            shape: StadiumBorder(),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Locating…',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Material(
            color: AppColors.navBar,
            borderRadius: BorderRadius.circular(12),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context
                        .read<LocationBloc>()
                        .add(const TrackPosition()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
