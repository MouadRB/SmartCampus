import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/activities/domain/entities/activity.dart';

/// Abstract contract for the campus-activities source. Inward-only Domain
/// import policy: only `dartz`, the shared `failures.dart`, and the local
/// [Activity] entity. The implementation lives in `data/` and is injected
/// at the DI tier.
///
/// `getUpcomingActivities()` is contracted to:
///   * filter to activities with `startsAt >= now`,
///   * sort ascending by `startsAt`,
///   * translate every transport / parse exception into a typed [Failure]
///     so the BLoC layer never needs `try`/`catch`.
///
/// `toggleRsvp(id)` flips the local user's RSVP state for a single activity
/// and adjusts `attendance` accordingly. The mock impl mutates in-memory
/// state; a future remote impl will POST and reconcile.
abstract class ActivitiesRepository {
  Future<Either<Failure, List<Activity>>> getUpcomingActivities();
  Future<Either<Failure, Activity>> toggleRsvp(int activityId);
}
