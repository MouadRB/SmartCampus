import 'package:dartz/dartz.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';

abstract class AnnouncementsRepository {
  Future<Either<Failure, List<Announcement>>> getAnnouncements();
}
