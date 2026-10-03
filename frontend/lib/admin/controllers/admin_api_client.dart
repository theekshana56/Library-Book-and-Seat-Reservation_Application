import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../api/api_client.dart';
import '../../models/book.dart';
import '../models/admin_models.dart';

class AdminApiClient {
  final http.Client _http;

  AdminApiClient({http.Client? client}) : _http = client ?? http.Client();

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${ApiClient.baseUrl}$path').replace(queryParameters: query);

  Future<AdminStats> getStats() async => AdminStats.fromJson(
    await _map(await _http.get(_uri('/api/v1/admin/stats'))),
  );

  Future<List<AdminUser>> getUsers({String? role, bool? active}) async {
    final query = <String, String>{
      'role': ?role,
      'active': ?active?.toString(),
    };
    return (await _list(await _http.get(_uri('/api/v1/admin/users', query))))
        .map(AdminUser.fromJson)
        .toList();
  }

  Future<AdminUser> createUser(Map<String, dynamic> payload) async =>
      AdminUser.fromJson(
        await _map(
          await _http.post(
            _uri('/api/v1/admin/users'),
            headers: _headers,
            body: jsonEncode(payload),
          ),
        ),
      );

  Future<AdminUser> setUserActive(String id, bool active) async =>
      AdminUser.fromJson(
        await _map(
          await _http.put(
            _uri('/api/v1/admin/users/$id/status'),
            headers: _headers,
            body: jsonEncode({'active': active}),
          ),
        ),
      );

  Future<List<PublisherProposal>> getProposals() async =>
      (await _list(await _http.get(_uri('/api/v1/admin/proposals'))))
          .map(PublisherProposal.fromJson)
          .toList();

  Future<List<PublisherProposal>> getVendorProposals(String vendorId) async =>
      (await _list(
        await _http.get(_uri('/api/v1/publisher/proposals/vendor/$vendorId')),
      )).map(PublisherProposal.fromJson).toList();

  Future<PublisherProposal> submitProposal(
    Map<String, dynamic> payload,
  ) async => PublisherProposal.fromJson(
    await _map(
      await _http.post(
        _uri('/api/v1/publisher/proposals'),
        headers: _headers,
        body: jsonEncode(payload),
      ),
    ),
  );

  Future<PublisherProposal> reviewProposal(
    String id, {
    required bool approved,
    int? quantity,
    String? message,
  }) async => PublisherProposal.fromJson(
    await _map(
      await _http.put(
        _uri('/api/v1/admin/proposals/$id/review'),
        headers: _headers,
        body: jsonEncode({
          'approved': approved,
          'requestedLotQty': quantity,
          'message': message,
        }),
      ),
    ),
  );

  Future<List<StaffTask>> getStaffTasks(String staffId) async =>
      (await _list(await _http.get(_uri('/api/v1/admin/tasks/staff/$staffId'))))
          .map(StaffTask.fromJson)
          .toList();

  Future<StaffTask> assignTask(Map<String, dynamic> payload) async =>
      StaffTask.fromJson(
        await _map(
          await _http.post(
            _uri('/api/v1/admin/tasks'),
            headers: _headers,
            body: jsonEncode(payload),
          ),
        ),
      );

  Future<StaffTask> updateTask(
    String id,
    String status, {
    String? shelfCode,
  }) async => StaffTask.fromJson(
    await _map(
      await _http.put(
        _uri('/api/v1/admin/tasks/$id/status'),
        headers: _headers,
        body: jsonEncode({'status': status, 'targetShelfCode': shelfCode}),
      ),
    ),
  );

  Future<List<LibraryShelf>> getShelves() async =>
      (await _list(await _http.get(_uri('/api/v1/admin/shelves'))))
          .map(LibraryShelf.fromJson)
          .toList();

  Future<LibraryShelf> saveShelf(
    Map<String, dynamic> payload, {
    String? id,
  }) async {
    final response = id == null
        ? await _http.post(
            _uri('/api/v1/admin/shelves'),
            headers: _headers,
            body: jsonEncode(payload),
          )
        : await _http.put(
            _uri('/api/v1/admin/shelves/$id'),
            headers: _headers,
            body: jsonEncode(payload),
          );
    return LibraryShelf.fromJson(await _map(response));
  }

  Future<List<LibraryHall>> getHalls() async =>
      (await _list(await _http.get(_uri('/api/v1/admin/halls'))))
          .map(LibraryHall.fromJson)
          .toList();

  Future<LibraryHall> createHall(Map<String, dynamic> payload) async =>
      LibraryHall.fromJson(
        await _map(
          await _http.post(
            _uri('/api/v1/admin/halls'),
            headers: _headers,
            body: jsonEncode(payload),
          ),
        ),
      );

  Future<List<LibrarySeat>> getSeats() async =>
      (await _list(await _http.get(_uri('/api/v1/admin/seats'))))
          .map(LibrarySeat.fromJson)
          .toList();

  Future<LibrarySeat> createSeat(Map<String, dynamic> payload) async =>
      LibrarySeat.fromJson(
        await _map(
          await _http.post(
            _uri('/api/v1/admin/seats'),
            headers: _headers,
            body: jsonEncode(payload),
          ),
        ),
      );

  Future<List<Book>> getPendingShelvingBooks() async => (await _list(
    await _http.get(_uri('/api/v1/admin/books/pending-shelving')),
  )).map(Book.fromJson).toList();

  static const _headers = {'Content-Type': 'application/json'};

  Future<Map<String, dynamic>> _map(http.Response response) async {
    _ensureOk(response);
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  Future<List<Map<String, dynamic>>> _list(http.Response response) async {
    _ensureOk(response);
    return (jsonDecode(response.body) as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  void _ensureOk(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message']?.toString() ??
            'Request failed (${response.statusCode})',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Request failed (${response.statusCode})');
    }
  }
}
