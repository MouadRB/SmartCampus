import 'package:equatable/equatable.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();
}

/// The BLoC's state before the first [checkConnectivity] result arrives.
/// The UI should treat this as indeterminate — neither show the offline
/// banner nor assume connectivity is available.
class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial();

  @override
  List<Object?> get props => [];
}

/// At least one active network interface is available. The UI hides the
/// offline banner and allows remote data fetches to proceed.
class ConnectedState extends ConnectivityState {
  const ConnectedState();

  @override
  List<Object?> get props => [];
}

/// All network interfaces report [ConnectivityResult.none]. The UI must
/// display the persistent amber offline banner (FR-NET-05) and suppress
/// any remote fetch attempts.
class DisconnectedState extends ConnectivityState {
  const DisconnectedState();

  @override
  List<Object?> get props => [];
}
