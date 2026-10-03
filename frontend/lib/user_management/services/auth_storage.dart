import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';

class AuthStorage {
  static const String _keyToken = 'biblione_auth_token';
  static const String _keyUser = 'biblione_auth_user';

  final FlutterSecureStorage _storage;

  // In-memory fallback if platform secure storage is not available in mock/test environments
  final Map<String, String> _memoryFallback = {};

  AuthStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveSession({
    required String token,
    required UserProfile user,
  }) async {
    try {
      await _storage
          .write(key: _keyToken, value: token)
          .timeout(const Duration(milliseconds: 1500));
      await _storage
          .write(key: _keyUser, value: jsonEncode(user.toJson()))
          .timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      _memoryFallback[_keyToken] = token;
      _memoryFallback[_keyUser] = jsonEncode(user.toJson());
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage
          .read(key: _keyToken)
          .timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      return _memoryFallback[_keyToken];
    }
  }

  Future<UserProfile?> getUser() async {
    try {
      final raw = await _storage
          .read(key: _keyUser)
          .timeout(const Duration(milliseconds: 1500));
      if (raw == null || raw.isEmpty) return null;
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      final raw = _memoryFallback[_keyUser];
      if (raw == null || raw.isEmpty) return null;
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
  }

  Future<void> saveUser(UserProfile user) async {
    try {
      await _storage
          .write(key: _keyUser, value: jsonEncode(user.toJson()))
          .timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      _memoryFallback[_keyUser] = jsonEncode(user.toJson());
    }
  }

  Future<void> clearSession() async {
    try {
      await _storage
          .delete(key: _keyToken)
          .timeout(const Duration(milliseconds: 1500));
      await _storage
          .delete(key: _keyUser)
          .timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      // ignore
    }
    _memoryFallback.remove(_keyToken);
    _memoryFallback.remove(_keyUser);
  }
}
