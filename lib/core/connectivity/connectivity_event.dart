import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();
}

/// Dispatched internally by [ConnectivityBloc] whenever the OS reports a
/// change in network interfaces, and once immediately on construction to
/// establish the initial known state.
///
/// [results] is a list because a device can be connected via multiple
/// interfaces simultaneously (e.g., WiFi + VPN). The BLoC treats the
/// connection as active if any result is not [ConnectivityResult.none].
class ConnectivityStatusChanged extends ConnectivityEvent {
  const ConnectivityStatusChanged(this.results);

  final List<ConnectivityResult> results;

  @override
  List<Object?> get props => [results];
}
