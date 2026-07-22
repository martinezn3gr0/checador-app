enum CheckadaType { entrada, salida }

enum CheckadaStatus { pending, verified, rejected }

class Checada {
  final String id;
  final String employeeId;
  final String obraId;
  final CheckadaType type;
  final CheckadaStatus status;
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
  
  Checada copyWith({
    String? id,
    String? employeeId,
    String? obraId,
    CheckadaType? type,
    CheckadaStatus? status,
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
}
