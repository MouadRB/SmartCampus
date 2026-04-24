import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  /// Human-readable description of the failure, propagated to the UI as the
  /// error message string displayed alongside the retry prompt (FR-NET-05).
  /// Concrete subclasses satisfy this via their [final String message] field.
  String get message;
}

class ServerFailure extends Failure {
  const ServerFailure({this.message = ''});

  final String message;

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure({this.message = ''});

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure({this.message = ''});

  final String message;

  @override
  List<Object?> get props => [message];
}
