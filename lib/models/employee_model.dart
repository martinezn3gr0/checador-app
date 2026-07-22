class Employee {
  final String id;
  final String companyId;
  final String code;
  final String fullName;
  final String email;
  final String position;
  final String? obraId;
  final String? obraName;
  final bool isActive;
  final DateTime createdAt;

  const Employee({
    required this.id,
    required this.companyId,
    required this.code,
    required this.fullName,
    required this.email,
    required this.position,
    this.obraId,
    this.obraName,
    required this.isActive,
    required this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      code: json['code'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String? ?? '',
      position: json['position'] as String? ?? '',
      obraId: json['obra_id'] as String?,
      obraName: json['obra_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'code': code,
      'full_name': fullName,
      'email': email,
      'position': position,
      'obra_id': obraId,
      'obra_name': obraName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
