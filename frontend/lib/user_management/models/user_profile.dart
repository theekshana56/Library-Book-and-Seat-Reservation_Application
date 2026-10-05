class UserProfile {
  final String id;
  final String? universityId;
  final String fullName;
  final String email;
  final String role;
  final String? department;
  final String? userCategory;
  final bool active;

  const UserProfile({
    required this.id,
    this.universityId,
    required this.fullName,
    required this.email,
    required this.role,
    this.department,
    this.userCategory,
    this.active = true,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      universityId: json['universityId'] as String?,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'STUDENT',
      department: json['department'] as String?,
      userCategory: json['userCategory'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (universityId != null) 'universityId': universityId,
      'fullName': fullName,
      'email': email,
      'role': role,
      if (department != null) 'department': department,
      if (userCategory != null) 'userCategory': userCategory,
      'active': active,
    };
  }

  UserProfile copyWith({
    String? id,
    String? universityId,
    String? fullName,
    String? email,
    String? role,
    String? department,
    String? userCategory,
    bool? active,
  }) {
    return UserProfile(
      id: id ?? this.id,
      universityId: universityId ?? this.universityId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      userCategory: userCategory ?? this.userCategory,
      active: active ?? this.active,
    );
  }
}
