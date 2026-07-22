import '../models/checada_model.dart';
import 'supabase_service.dart';

class AttendanceRpcService {
  final SupabaseService _supabaseService;

  AttendanceRpcService(this._supabaseService);

  Future<Checada> registerCheck({
    required String employeeId,
    required ChecadaType type,
    required double latitude,
    required double longitude,
    String? photoPath,
    bool biometricVerified = false,
  }) async {
    final response = await _supabaseService.callRpc(
      'employee_register_check',
      params: {
        'p_employee_id': employeeId,
        'p_type': type.name,
        'p_latitude': latitude,
        'p_longitude': longitude,
        'p_photo_path': photoPath,
        'p_biometric_verified': biometricVerified,
      },
    );

    if (response is Map) {
      return Checada.fromJson(Map<String, dynamic>.from(response));
    }

    if (response is List && response.isNotEmpty) {
      final first = response.first;
      if (first is Map) {
        return Checada.fromJson(Map<String, dynamic>.from(first));
      }
    }

    throw StateError('Unexpected attendance RPC response: $response');
  }

  Future<List<Checada>> fetchHistory({
    required String employeeId,
    int limit = 30,
  }) async {
    final response = await _supabaseService.callRpc(
      'employee_check_history',
      params: {
        'p_employee_id': employeeId,
        'p_limit': limit,
      },
    );

    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) => Checada.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return const [];
  }
}
