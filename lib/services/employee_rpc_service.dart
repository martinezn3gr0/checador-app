import '../core/routing/app_routes.dart';
import '../models/dashboard_metric_model.dart';
import '../models/employee_model.dart';
import 'supabase_service.dart';

class EmployeeRpcService {
  final SupabaseService _supabaseService;

  EmployeeRpcService(this._supabaseService);

  Future<Employee> createEmployee({
    required String companyId,
    required String fullName,
    required String email,
    required String position,
    String? obraId,
  }) async {
    final response = await _supabaseService.callRpc(
      'admin_create_employee_with_credentials',
      params: {
        'p_company_id': companyId,
        'p_full_name': fullName.trim(),
        'p_email': email.trim(),
        'p_position': position.trim(),
        'p_obra_id': obraId,
      },
    );

    return Employee.fromJson(_extractPayload(response));
  }

  Future<void> regeneratePin({
    required String employeeId,
    required String requestedByUserId,
  }) {
    return _supabaseService.callRpc(
      'admin_regenerate_employee_pin',
      params: {
        'p_employee_id': employeeId,
        'p_requested_by_user_id': requestedByUserId,
      },
    );
  }

  Future<List<Employee>> fetchEmployees({
    required String companyId,
    bool? isActive,
    String? obraId,
  }) async {
    final response = await _supabaseService.callRpc(
      'admin_list_employees',
      params: {
        'p_company_id': companyId,
        'p_is_active': isActive,
        'p_obra_id': obraId,
      },
    );

    return _extractList(response).map(Employee.fromJson).toList();
  }

  Future<List<DashboardMetric>> fetchDashboardMetrics({
    required String companyId,
  }) async {
    final response = await _supabaseService.callRpc(
      'admin_dashboard_metrics',
      params: {'p_company_id': companyId},
    );

    final fromRpc = _extractList(response).map(DashboardMetric.fromJson);
    final metrics = fromRpc.toList();

    if (metrics.isNotEmpty) {
      return metrics;
    }

    return const [
      DashboardMetric(
        id: 'active-employees',
        title: 'Empleados activos',
        value: 0,
        route: AppRoutes.adminEmployees,
        filters: {'is_active': true},
      ),
      DashboardMetric(
        id: 'today-checks',
        title: 'Checadas hoy',
        value: 0,
        route: AppRoutes.employeeHistory,
        filters: {'date': 'today'},
      ),
      DashboardMetric(
        id: 'today-absences',
        title: 'Faltas hoy',
        value: 0,
        route: AppRoutes.adminEmployees,
        filters: {'attendance_status': 'absent', 'date': 'today'},
      ),
    ];
  }

  Map<String, dynamic> _extractPayload(dynamic response) {
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    if (response is List && response.isNotEmpty) {
      final first = response.first;
      if (first is Map) {
        return Map<String, dynamic>.from(first);
      }
    }

    throw StateError('Unexpected employee RPC response: $response');
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    if (response == null) {
      return const [];
    }

    if (response is List) {
      return response
          .whereType<Map>()
          .map(Map<String, dynamic>.from)
          .toList();
    }

    if (response is Map) {
      return [Map<String, dynamic>.from(response)];
    }

    return const [];
  }
}
