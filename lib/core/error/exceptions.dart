/// Thrown by the Remote Data Source when the server returns a non-200 status.
/// The Repository layer catches this and maps it to a [ServerFailure].
class ServerException implements Exception {
  const ServerException({required this.statusCode, this.message = ''});

  final int statusCode;
  final String message;

  @override
  String toString() =>
      'ServerException(statusCode: $statusCode, message: $message)';
}

/// Thrown by the Remote Data Source when the request times out or there is
/// no network connectivity (e.g. [SocketException]).
/// The Repository layer catches this and maps it to a [NetworkFailure],
/// which drives the Offline/Slow Connection banner in the UI.
class NetworkException implements Exception {
  const NetworkException({this.message = 'Request timed out'});

  final String message;

  @override
  String toString() => 'NetworkException(message: $message)';
}
