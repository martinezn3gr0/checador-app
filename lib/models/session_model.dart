enum UserRole { admin, employee }

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.employee:
        return 'employee';
    }
  }

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.employee:
        return 'Empleado';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return UserRole.admin;
      case 'employee':
      case 'empleado':
        return UserRole.employee;
      default:
        throw ArgumentError('Unknown user role: $value');
    }
  }
}

class AppSession {
  final String userId;
  final String userCode;
  final String accessToken;
  final UserRole role;
  final String? companyId;
  final DateTime createdAt;

  const AppSession({
    required this.userId,
    required this.userCode,
    required this.accessToken,
    required this.role,
    this.companyId,
    required this.createdAt,
  });

  factory AppSession.fromJson(Map<String, dynamic> json) {
    return AppSession(
      userId: json['user_id'] as String,
      userCode: json['user_code'] as String,
      accessToken: json['access_token'] as String,
      role: UserRoleX.fromString(json['role'] as String),
      companyId: json['company_id'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_code': userCode,
      'access_token': accessToken,
      'role': role.value,
      'company_id': companyId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppSession copyWith({
    String? userId,
    String? userCode,
    String? accessToken,
    UserRole? role,
    String? companyId,
    DateTime? createdAt,
  }) {
    return AppSession(
      userId: userId ?? this.userId,
      userCode: userCode ?? this.userCode,
      accessToken: accessToken ?? this.accessToken,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
