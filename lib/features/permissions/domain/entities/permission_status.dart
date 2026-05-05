/// Pure Domain enum for runtime permission state. Defined here so the
/// Domain and Presentation layers never import the `permission_handler`
/// package directly. The Data layer's `PermissionStatusMapper` translates
/// the package's enum to one of these three values.
///
/// FR-PERM-03 maps directly to these three values:
///   * State A (initial request)         → request flow re-enters and
///     terminates in [granted] or [denied].
///   * State B (rationale on first deny) → [denied].
///   * State C (settings redirect)       → [permanentlyDenied].
enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}
