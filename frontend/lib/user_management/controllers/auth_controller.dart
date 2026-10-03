import 'package:flutter/foundation.dart';
import '../../api/api_client.dart';
import '../models/user_profile.dart';
import '../services/auth_api_client.dart';
import '../services/auth_storage.dart';

class AuthController extends ChangeNotifier {
  final AuthApiClient _apiClient;
  final AuthStorage _storage;

  UserProfile? _currentUser;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  AuthController({
    AuthApiClient? apiClient,
    AuthStorage? storage,
  })  : _apiClient = apiClient ?? AuthApiClient(),
        _storage = storage ?? AuthStorage();

  bool get isAuthenticated => _token != null && _currentUser != null;
  UserProfile? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  static String currentInitials = 'KD';
  static UserProfile? currentProfile;

  static String getInitialsForName(String? name) {
    if (name == null || name.trim().isEmpty) return 'KD';
    final trimmed = name.trim();
    final parts = trimmed
        .split(RegExp(r'[\s\.\-_]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'KD';
    if (parts.length == 1) {
      final s = parts[0];
      return s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase();
    }
    final firstChar = parts.first[0].toUpperCase();
    final lastChar = parts.last[0].toUpperCase();
    return '$firstChar$lastChar';
  }

  void _updateCurrentInitials(UserProfile? user) {
    currentProfile = user;
    if (user != null && user.fullName.isNotEmpty) {
      currentInitials = getInitialsForName(user.fullName);
    } else {
      currentInitials = 'KD';
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedUser = await _storage.getUser();
      if (savedUser != null) {
        _currentUser = savedUser;
        _updateCurrentInitials(savedUser);
      }

      final savedToken = await _storage.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        try {
          final profile = await _apiClient.getProfile(savedToken);
          _token = savedToken;
          _currentUser = profile;
          _updateCurrentInitials(profile);
          await _storage.saveUser(profile);
        } catch (_) {
          // Token expired or invalid
          if (_currentUser == null) {
            await _storage.clearSession();
            _token = null;
            _currentUser = null;
            _updateCurrentInitials(null);
          }
        }
      } else {
        if (_currentUser == null) {
          _token = null;
          _currentUser = null;
          _updateCurrentInitials(null);
        }
      }
    } catch (_) {
      _token = null;
      _currentUser = null;
      _updateCurrentInitials(null);
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _apiClient.login(
        identifier: identifier,
        password: password,
      );
      _token = session.token;
      _currentUser = session.user;
      _updateCurrentInitials(session.user);
      await _storage.saveSession(token: session.token, user: session.user);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during login.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String universityId,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.register(
        fullName: fullName,
        universityId: universityId,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during registration.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    String? department,
  }) async {
    if (_token == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _apiClient.updateProfile(
        token: _token!,
        fullName: fullName,
        email: email,
        department: department,
      );
      _currentUser = updated;
      _updateCurrentInitials(updated);
      await _storage.saveUser(updated);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update profile.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (_token == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.changePassword(
        token: _token!,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      // Invalidate local session since password change revokes all server sessions
      await logout();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to change password.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      await _apiClient.logout(_token!);
    }
    await _storage.clearSession();
    _token = null;
    _currentUser = null;
    _updateCurrentInitials(null);
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
