import 'package:dartz/dartz.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/events/domain/entities/event_media.dart';

abstract class EventsRepository {
  Future<Either<Failure, List<EventMedia>>> getEventGallery();
}
