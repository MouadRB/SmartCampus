import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_event.dart';
import 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc() : super(const ConnectivityInitial()) {
    on<ConnectivityStatusChanged>(_onStatusChanged);

    // Subscribe to OS-level network change events for the lifetime of this
    // BLoC. Every emission dispatches a ConnectivityStatusChanged event so
    // all state transitions are traceable through the event log.
    _subscription = Connectivity().onConnectivityChanged.listen(
      (results) => add(ConnectivityStatusChanged(results)),
    );

    // Eagerly resolve the current connectivity state. Without this call the
    // BLoC stays in ConnectivityInitial until the first network change, which
    // may never happen on a stable connection.
    Connectivity().checkConnectivity().then(
      (results) => add(ConnectivityStatusChanged(results)),
    );
  }

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  void _onStatusChanged(
    ConnectivityStatusChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    // The device is considered online if at least one interface is active.
    // ConnectivityResult.none is the only value that indicates no connection.
    final isConnected = event.results.any(
      (result) => result != ConnectivityResult.none,
    );
    emit(isConnected ? const ConnectedState() : const DisconnectedState());
  }

  @override
  Future<void> close() {
    // Cancel the OS stream subscription before the BLoC is disposed.
    // Omitting this would leave an orphaned listener referencing a closed
    // BLoC, causing a memory leak for the lifetime of the process.
    _subscription.cancel();
    return super.close();
  }
}
