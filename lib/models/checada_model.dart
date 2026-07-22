enum ChecadaType { entrada, salida }

enum ChecadaStatus { pending, verified, rejected }

typedef CheckadaType = ChecadaType;
typedef CheckadaStatus = ChecadaStatus;

class Checada {
  final String id;
  final String employeeId;
  final String obraId;
  final ChecadaType type;
  final ChecadaStatus status;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final String? photoUrl;
  final bool biometricVerified;
  final String? notes;
  final DateTime createdAt;

  const Checada({
    required this.id,
    required this.employeeId,
    required this.obraId,
    required this.type,
    required this.status,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.distance,
    this.photoUrl,
    required this.biometricVerified,
    this.notes,
    required this.createdAt,
  });

  factory Checada.fromJson(Map<String, dynamic> json) {
    return Checada(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      obraId: json['obra_id'] as String,
      type: _typeFromString(json['type'] as String? ?? 'entrada'),
      status: _statusFromString(json['status'] as String? ?? 'pending'),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      latitude: _toDoubleOrNull(json['latitude']),
      longitude: _toDoubleOrNull(json['longitude']),
      distance: _toDoubleOrNull(json['distance_meters'] ?? json['distance']),
      photoUrl: json['photo_url'] as String?,
      biometricVerified: json['biometric_verified'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'obra_id': obraId,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'distance_meters': distance,
      'photo_url': photoUrl,
      'biometric_verified': biometricVerified,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Checada copyWith({
    String? id,
    String? employeeId,
    String? obraId,
    ChecadaType? type,
    ChecadaStatus? status,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? distance,
    String? photoUrl,
    bool? biometricVerified,
    String? notes,
    DateTime? createdAt,
  }) {
    return Checada(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      obraId: obraId ?? this.obraId,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      photoUrl: photoUrl ?? this.photoUrl,
      biometricVerified: biometricVerified ?? this.biometricVerified,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static ChecadaType _typeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'salida':
      case 'out':
        return ChecadaType.salida;
      case 'entrada':
      case 'in':
      default:
        return ChecadaType.entrada;
    }
  }

  static ChecadaStatus _statusFromString(String value) {
    switch (value.toLowerCase()) {
      case 'verified':
      case 'verificada':
        return ChecadaStatus.verified;
      case 'rejected':
      case 'rechazada':
        return ChecadaStatus.rejected;
      case 'pending':
      case 'pendiente':
      default:
        return ChecadaStatus.pending;
    }
  }

  static double? _toDoubleOrNull(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}
