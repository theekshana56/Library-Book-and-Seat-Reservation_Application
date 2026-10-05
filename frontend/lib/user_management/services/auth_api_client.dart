import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/api_client.dart';
import '../models/auth_session.dart';
import '../models/user_profile.dart';

class AuthApiClient {
  final String _baseUrl;
  final http.Client _client;

  AuthApiClient({String? baseUrl, http.Client? client})
      : _baseUrl = (baseUrl != null && baseUrl.isNotEmpty)
            ? baseUrl
            : ApiClient.baseUrl,
        _client = client ?? http.Client();

  String get baseUrl => _baseUrl;

  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/login');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier.trim(),
        'password': password,
      }),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthSession.fromJson(data);
  }

  Future<UserProfile> register({
    required String fullName,
    required String universityId,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/register');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName.trim(),
        'universityId': universityId.trim(),
        'email': email.trim(),
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> registerVendor({
    required String fullName,
    required String companyName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/register/vendor');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName.trim(),
        'companyName': companyName.trim(),
        'email': email.trim(),
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> getProfile(String token) async {
    final uri = Uri.parse('$_baseUrl/api/v1/users/me');
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateProfile({
    required String token,
    required String fullName,
    required String email,
    String? department,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/users/me');
    final response = await _client.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fullName': fullName.trim(),
        'email': email.trim(),
        'department': department?.trim(),
      }),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/users/me/password');
    final response = await _client.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      }),
    );
    _ensureSuccess(response);
  }

  Future<void> logout(String token) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/logout');
    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      _ensureSuccess(response);
    } catch (_) {
      // Best effort remote revocation
    }
  }

  void _ensureSuccess(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    try {
      final body = jsonDecode(res.body);
      final msg = body['message']?.toString();
      if (msg != null && msg.isNotEmpty) {
        throw ApiException(msg);
      }
      throw ApiException('Request failed (${res.statusCode})');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unable to communicate with Biblione API at $_baseUrl');
    }
  }
}
