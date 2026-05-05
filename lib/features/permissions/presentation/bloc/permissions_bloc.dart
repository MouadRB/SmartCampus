import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_status.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_type.dart';
import 'package:smart_campus/features/permissions/domain/usecases/check_permission.dart';
import 'package:smart_campus/features/permissions/domain/usecases/open_app_settings.dart';
import 'package:smart_campus/features/permissions/domain/usecases/request_permission.dart';
import 'package:smart_campus/features/permissions/presentation/bloc/permissions_event.dart';
import 'package:smart_campus/features/permissions/presentation/bloc/permissions_state.dart';

/// Routes [PermissionsEvent]s through the use cases and emits exactly one
/// terminal [PermissionsState] per event. Honours the No-Try-Catch
/// invariant (WEEK2 §3.2): every failure mode arrives as a typed [Failure]
/// from the repository, so this class only `.fold()`s — it never `try`s.
class PermissionsBloc extends Bloc<PermissionsEvent, PermissionsState> {
  PermissionsBloc({
    required this.checkPermission,
    required this.requestPermission,
    required this.openAppSettings,
  }) : super(const PermissionsInitial()) {
    on<CheckPermissionRequested>(_onCheck);
    on<RequestPermissionRequested>(_onRequest);
    on<OpenSettingsRequested>(_onOpenSettings);
  }

  final CheckPermission checkPermission;
  final RequestPermission requestPermission;
  final OpenAppSettings openAppSettings;

  Future<void> _onCheck(
    CheckPermissionRequested event,
    Emitter<PermissionsState> emit,
  ) async {
    emit(const PermissionsLoading());
    final result = await checkPermission(event.type);
    _emitFromStatusResult(result, event.type, emit);
  }

  Future<void> _onRequest(
    RequestPermissionRequested event,
    Emitter<PermissionsState> emit,
  ) async {
    emit(const PermissionsLoading());
    final result = await requestPermission(event.type);
    _emitFromStatusResult(result, event.type, emit);
  }

  Future<void> _onOpenSettings(
    OpenSettingsRequested event,
    Emitter<PermissionsState> emit,
  ) async {
    final result = await openAppSettings();
    result.fold(
      (failure) => emit(PermissionsError(failure.message)),
      // No state change on success: the OS settings screen is now in the
      // foreground; the gate will re-check permission state on resume.
      (_) {},
    );
  }

  void _emitFromStatusResult(
    Either<Failure, PermissionStatus> result,
    PermissionType type,
    Emitter<PermissionsState> emit,
  ) {
    result.fold(
      (failure) {
        if (failure is PermissionFailure) {
          emit(
            failure.permanent
                ? PermissionPermanentlyDenied(type, failure.message)
                : PermissionDenied(type, failure.message),
          );
        } else {
          emit(PermissionsError(failure.message));
        }
      },
      (status) {
        switch (status) {
          case PermissionStatus.granted:
            emit(PermissionGranted(type));
          case PermissionStatus.permanentlyDenied:
            emit(
              PermissionPermanentlyDenied(
                type,
                'Permission permanently denied',
              ),
            );
          case PermissionStatus.denied:
            emit(PermissionDenied(type, 'Permission denied'));
        }
      },
    );
  }
}
