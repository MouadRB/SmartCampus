/// Identifies which OS-level permission is being requested. Held as a pure
/// Domain enum so consumers (LocationRepository, future CameraRepository,
/// PermissionsBloc events) can speak in domain language without coupling to
/// the `permission_handler` package's `Permission` constants.
///
/// Add new entries here as new hardware features come online.
enum PermissionType {
  /// `ACCESS_FINE_LOCATION` (Android) / "When In Use" (iOS). FR-PERM-02.
  location,

  /// Camera + photo library. FR-PERM-01. Reserved for the Events feature
  /// "Attach Photo" flow; not yet wired through.
  camera,
}
