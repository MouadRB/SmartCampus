import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/activities/domain/entities/activity.dart';
import 'package:smart_campus/features/activities/domain/repositories/activities_repository.dart';

/// Use case: resolve the list of upcoming campus activities. Pure
/// call-through — the repository owns filtering / sorting / failure
/// translation, so this class stays a 3-line wrapper that the eventual
/// `ActivitiesBloc` will own as a `final` field.
class GetUpcomingActivities {
  const GetUpcomingActivities(this.repository);

  final ActivitiesRepository repository;

  Future<Either<Failure, List<Activity>>> call() =>
      repository.getUpcomingActivities();
}
