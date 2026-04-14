import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../error/exceptions.dart';
import '../network/network_client.dart';
import '../../features/announcements/data/models/announcement_model.dart';
import '../../features/auth/data/models/user_profile_model.dart';
import '../../features/events/data/models/event_media_model.dart';
import '../../features/map/data/models/campus_location_model.dart';
import '../../features/timetable/data/models/campus_task_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Contract
// ─────────────────────────────────────────────────────────────────────────────

/// Defines every remote operation the app needs from JSONPlaceholder.
/// Depend on this abstraction, not on [SmartCampusRemoteDataSourceImpl],
/// so the concrete HTTP client can be swapped without touching callers.
abstract class SmartCampusRemoteDataSource {
  /// Fetches all posts from `/posts` and returns them as [AnnouncementModel]s.
  Future<List<AnnouncementModel>> getAnnouncements();

  /// Fetches the fixed student profile from `/users/1`.
  Future<UserProfileModel> getProfile();

  /// Fetches all to-do items from `/todos` as [CampusTaskModel]s.
  Future<List<CampusTaskModel>> getTasks();

  /// Fetches all user entries from `/users` and maps their geo coordinates
  /// to [CampusLocationModel]s for the campus map.
  Future<List<CampusLocationModel>> getMapLocations();

  /// Fetches all photos from `/photos` and groups them by album (event)
  /// as [EventMediaModel]s.
  Future<List<EventMediaModel>> getEventGallery();
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementation
// ─────────────────────────────────────────────────────────────────────────────

class SmartCampusRemoteDataSourceImpl implements SmartCampusRemoteDataSource {
  SmartCampusRemoteDataSourceImpl({required this.client});

  final http.Client client;

  // ── Private helper ────────────────────────────────────────────────────────

  /// Executes a GET request to [kBaseUrl][endpoint] with [kRequestTimeout].
  ///
  /// Returns the decoded JSON body on HTTP 200.
  ///
  /// Throws:
  /// - [ServerException]  — any non-200 HTTP status code.
  /// - [NetworkException] — [TimeoutException] (slow/no response) or
  ///                        [SocketException] (no connectivity).
  Future<dynamic> _get(String endpoint) async {
    try {
      final response = await client
          .get(Uri.parse('$kBaseUrl$endpoint'))
          .timeout(kRequestTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      throw ServerException(
        statusCode: response.statusCode,
        message: 'HTTP ${response.statusCode} on $endpoint',
      );
    } on TimeoutException {
      throw const NetworkException(
        message: 'Connection timed out after 10 seconds',
      );
    } on SocketException catch (e) {
      throw NetworkException(message: 'No internet connection: ${e.message}');
    }
  }

  // ── Public methods ────────────────────────────────────────────────────────

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    final data = await _get('/posts') as List<dynamic>;
    return data
        .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserProfileModel> getProfile() async {
    final data = await _get('/users/1') as Map<String, dynamic>;
    return UserProfileModel.fromJson(data);
  }

  @override
  Future<List<CampusTaskModel>> getTasks() async {
    final data = await _get('/todos') as List<dynamic>;
    return data
        .map((e) => CampusTaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CampusLocationModel>> getMapLocations() async {
    final data = await _get('/users') as List<dynamic>;
    return data
        .map((e) => CampusLocationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<EventMediaModel>> getEventGallery() async {
    final data = await _get('/photos') as List<dynamic>;
    return data
        .map((e) => EventMediaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
