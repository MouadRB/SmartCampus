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

/// Thrown by any Local Data Source when a Drift read or write operation fails.
/// The Repository layer catches this and maps it to a [CacheFailure].
class CacheException implements Exception {
  const CacheException({this.message = 'Local database operation failed'});

  final String message;

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Thrown by the Permissions Data Source (or by hardware data sources that
/// gate on a permission) when the user has denied or permanently denied a
/// runtime permission. The Repository layer catches this and maps it to a
/// [PermissionFailure].
class PermissionDeniedException implements Exception {
  const PermissionDeniedException({
    this.message = 'Permission denied',
    this.permanent = false,
  });

  final String message;

  /// True when the user has selected "Don't ask again" / has permanently
  /// denied the permission. The UI must redirect to system settings rather
  /// than re-prompting (FR-PERM-03 State C).
  final bool permanent;

  @override
  String toString() =>
      'PermissionDeniedException(message: $message, permanent: $permanent)';
}

/// Thrown by the Location Data Source when the device's location services
/// are switched off at the OS level (Settings → Location → off). Distinct
/// from [PermissionDeniedException]: the app permission may be granted but
/// the hardware service is unavailable.
class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException({
    this.message = 'Location services are disabled on this device',
  });

  final String message;

  @override
  String toString() => 'LocationServiceDisabledException(message: $message)';
}
