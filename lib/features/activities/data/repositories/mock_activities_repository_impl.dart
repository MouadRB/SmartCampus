import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/activities/data/models/activity_model.dart';
import 'package:smart_campus/features/activities/domain/entities/activity.dart';
import 'package:smart_campus/features/activities/domain/repositories/activities_repository.dart';

/// In-memory implementation of [ActivitiesRepository] used while the remote
/// catalogue endpoint is not yet available. Returns a hardcoded set of
/// Constantine-campus activities anchored to `DateTime.now()` so the
/// `startsAt >= now` filter stays meaningful across days.
///
/// State (`_seed`) is mutable so RSVP toggles persist across BLoC re-fetches
/// for the lifetime of the app process — sufficient for a mock.
class MockActivitiesRepositoryImpl implements ActivitiesRepository {
  MockActivitiesRepositoryImpl();

  List<ActivityModel>? _seed;

  @override
  Future<Either<Failure, List<Activity>>> getUpcomingActivities() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    _seed ??= _buildSeed(now);

    final upcoming = _seed!
        .where((a) => a.startsAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    return Right<Failure, List<Activity>>(List<Activity>.of(upcoming));
  }

  @override
  Future<Either<Failure, Activity>> toggleRsvp(int activityId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final list = _seed ??= _buildSeed(DateTime.now());
    final idx = list.indexWhere((a) => a.id == activityId);
    if (idx < 0) {
      return const Left(ServerFailure(message: 'Activity not found'));
    }

    final current = list[idx];
    final goingNow = current.rsvpStatus == RsvpStatus.going;
    final cap = current.capacity == 0 ? 1 << 31 : current.capacity;
    final updated = ActivityModel(
      id: current.id,
      title: current.title,
      description: current.description,
      startsAt: current.startsAt,
      endsAt: current.endsAt,
      location: current.location,
      category: current.category,
      imageUrl: current.imageUrl,
      aboutLong: current.aboutLong,
      capacity: current.capacity,
      attendance: goingNow
          ? (current.attendance - 1).clamp(0, cap)
          : (current.attendance + 1).clamp(0, cap),
      rsvpStatus: goingNow ? RsvpStatus.none : RsvpStatus.going,
    );
    list[idx] = updated;
    return Right<Failure, Activity>(updated);
  }

  List<ActivityModel> _buildSeed(DateTime now) => [
        ActivityModel(
          id: 1,
          title: 'NTIC Midterm — Operating Systems',
          description:
              'Mid-semester evaluation for the Faculté NTIC, S5 cohort.',
          aboutLong:
              'Mid-semester evaluation for the Faculté NTIC, S5 cohort. '
              'Topics: process scheduling, virtual memory, file systems, '
              'and synchronisation primitives. Bring your student card; no '
              'electronic devices allowed.',
          startsAt: now.add(const Duration(days: 1, hours: 3)),
          endsAt: now.add(const Duration(days: 1, hours: 5)),
          location: 'Le Bloc P · Amphi 5',
          category: 'academic',
          attendance: 184,
          capacity: 240,
        ),
        ActivityModel(
          id: 2,
          title: 'GEEKS Club — Recruitment Session',
          description:
              'Open info session for new members of the NTIC GEEKS Club.',
          aboutLong:
              "GEEKS — the Faculté NTIC's flagship student club — opens its "
              'doors for the new academic year. Discover ongoing tracks: '
              'web, mobile, AI, cybersecurity, and competitive programming. '
              'Q&A with the bureau and a short coding warm-up.',
          startsAt: now.add(const Duration(days: 2, hours: 2)),
          endsAt: now.add(const Duration(days: 2, hours: 4)),
          location: 'Le Bloc P · Salle de conférence NTIC',
          category: 'club',
          attendance: 56,
          capacity: 120,
        ),
        ActivityModel(
          id: 3,
          title: 'IT-Revolution Hackathon — Kickoff',
          description:
              '48-hour campus hackathon hosted by Club IT-Revolution.',
          aboutLong:
              'Two days of building, mentoring, and shipping. Tracks include '
              'EdTech for the Algerian campus, Arabic NLP, and applied AI. '
              'Mixed teams of 3–5 from any faculty (NTIC, MI, …). Meals and '
              'snacks provided. Amphi 5 for the kickoff and final pitches; '
              'Le Bloc P labs reserved for hacking through the night.',
          startsAt: now.add(const Duration(days: 4, hours: 4)),
          endsAt: now.add(const Duration(days: 6, hours: 18)),
          location: 'Amphi 5 — Université Constantine 2',
          category: 'workshop',
          attendance: 92,
          capacity: 150,
        ),
        ActivityModel(
          id: 4,
          title: 'MI Study Group — Algebra Finals Prep',
          description:
              'Peer-led prep session for Faculté MI algebra finals.',
          aboutLong:
              'Open study group covering linear algebra, group theory, and '
              "the tricky proof questions from last year's MI finals. "
              'Bring past papers; whiteboards provided.',
          startsAt: now.add(const Duration(days: 5, hours: 3)),
          endsAt: now.add(const Duration(days: 5, hours: 6)),
          location: 'Bibliothèque universitaire — Salle d\'étude 2',
          category: 'academic',
          attendance: 28,
          capacity: 50,
        ),
        ActivityModel(
          id: 5,
          title: 'Guest Lecture — Cybersecurity in 2026',
          description:
              'Industry talk on the post-quantum threat landscape.',
          aboutLong:
              'A guest lecture from a senior security engineer working out '
              'of Algiers. Topics: post-quantum cryptography, supply-chain '
              'attacks, and what new graduates can do to break into the '
              'field. Open to all faculties — NTIC, MI, and beyond.',
          startsAt: now.add(const Duration(days: 7, hours: 5)),
          endsAt: now.add(const Duration(days: 7, hours: 7)),
          location: 'Amphi 5 — Université Constantine 2',
          category: 'lecture',
          attendance: 73,
          capacity: 240,
        ),
        ActivityModel(
          id: 6,
          title: 'NTIC End-of-Semester Social',
          description:
              'Wind down the semester with music, food, and good company.',
          aboutLong:
              'Faculté NTIC end-of-semester social. Light snacks, student '
              'DJ set, and a short awards segment for the most active club '
              'members of the term. Free entry for NTIC and MI students.',
          startsAt: now.add(const Duration(days: 9, hours: 6)),
          endsAt: now.add(const Duration(days: 9, hours: 9)),
          location: 'Le Bloc P — Hall principal',
          category: 'social',
          attendance: 110,
          capacity: 250,
        ),
      ];
}
