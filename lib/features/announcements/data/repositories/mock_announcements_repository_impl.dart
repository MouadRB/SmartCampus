import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/announcements/data/models/announcement_model.dart';
import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';
import 'package:smart_campus/features/announcements/domain/repositories/announcements_repository.dart';

/// In-memory mock that returns Université Constantine 2 Abdelhamid Mehri
/// announcements. Replaces the JSONPlaceholder-backed real impl while a
/// proper backend is not available; preserves the same Domain contract.
class MockAnnouncementsRepositoryImpl implements AnnouncementsRepository {
  MockAnnouncementsRepositoryImpl();

  List<AnnouncementModel>? _seed;

  @override
  Future<Either<Failure, List<Announcement>>> getAnnouncements() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    _seed ??= _buildSeed(now);

    final sorted = List<AnnouncementModel>.from(_seed!)
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return Right<Failure, List<Announcement>>(List<Announcement>.of(sorted));
  }

  List<AnnouncementModel> _buildSeed(DateTime now) => [
        AnnouncementModel(
          id: 101,
          userId: 1,
          title: 'GEEKS Club — Recruitment officially open',
          body:
              'The GEEKS Club, hosted by the Faculté NTIC at Université '
              'Constantine 2, has opened applications for the new academic '
              'year. Tracks: web, mobile, AI, cybersecurity, competitive '
              'programming. Walk-ins welcome at the Salle de conférence '
              'NTIC, Le Bloc P. Online form linked on the club page.',
          publishedAt: now.subtract(const Duration(hours: 2)),
        ),
        AnnouncementModel(
          id: 102,
          userId: 1,
          title: 'IT-Revolution — 48h Hackathon kickoff this weekend',
          body:
              'Club IT-Revolution invites all students of Université '
              'Constantine 2 — NTIC, MI, and beyond — to its annual 48-hour '
              'hackathon. Tracks include EdTech, Arabic NLP, and applied '
              'AI. Kickoff at Amphi 5, hacking through the night in Le '
              'Bloc P labs. Free meals, mentors on site, and prizes for the '
              'top three teams.',
          publishedAt: now.subtract(const Duration(hours: 6)),
        ),
        AnnouncementModel(
          id: 103,
          userId: 2,
          title: 'Faculté NTIC — Exam schedule released',
          body:
              'The exam schedule for the Faculté NTIC (S1, S3, S5) has been '
              'published on the official notice board. All exams take place '
              'in Le Bloc P or Amphi 5 between 23 May and 8 June. Students '
              'are reminded to bring their student card and to arrive at '
              'least 15 minutes before the start time.',
          publishedAt: now.subtract(const Duration(days: 1, hours: 1)),
        ),
        AnnouncementModel(
          id: 104,
          userId: 2,
          title: 'Faculté MI — Algebra & Analyse exam timetable',
          body:
              'The Mathématiques-Informatique (MI) finals timetable is '
              'available. Algebra, Analyse, and Probabilités exams run from '
              '25 May to 5 June, mostly in Le Bloc P. Make-up sessions '
              'will be announced on the MI department page.',
          publishedAt: now.subtract(const Duration(days: 1, hours: 4)),
        ),
        AnnouncementModel(
          id: 105,
          userId: 3,
          title: 'Bibliothèque universitaire — Extended hours during finals',
          body:
              'During the finals period (23 May → 10 June), the '
              'Bibliothèque universitaire of Université Constantine 2 will '
              'extend its opening hours: 08:00 → 22:00 on weekdays, 09:00 '
              '→ 18:00 on Saturdays. Quiet study rooms can be reserved on '
              'a first-come basis at the main desk.',
          publishedAt: now.subtract(const Duration(days: 2, hours: 3)),
        ),
        AnnouncementModel(
          id: 106,
          userId: 4,
          title: 'DSI — Eduroam Wi-Fi maintenance Friday 02:00 → 04:00',
          body:
              'The Direction des Systèmes d\'Information (DSI) will perform '
              'scheduled maintenance on the Eduroam network this Friday '
              'between 02:00 and 04:00. Coverage in Le Bloc P, Amphi 5, '
              'and the Bibliothèque universitaire may be intermittent '
              'during this window. The wired network is unaffected.',
          publishedAt: now.subtract(const Duration(days: 3, hours: 2)),
        ),
      ];
}
