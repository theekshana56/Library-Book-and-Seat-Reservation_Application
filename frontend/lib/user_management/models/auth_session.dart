import 'user_profile.dart';

class AuthSession {
  final String token;
  final String tokenType;
  final DateTime? expiresAt;
  final UserProfile user;

  const AuthSession({
    required this.token,
    this.tokenType = 'Bearer',
    this.expiresAt,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'tokenType': tokenType,
      'expiresAt': expiresAt?.toIso8601String(),
      'user': user.toJson(),
    };
  }
}
