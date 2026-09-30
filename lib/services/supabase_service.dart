import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/checada_model.dart';
import '../models/entities.dart';
import '../utils/logger.dart';

/// Production data layer over Supabase RPCs (PIN hashes never leave the DB).
///
/// Tables: empresas, empleados, administradores, obras, empleado_obras, checadas.
/// When Supabase is not configured, methods return null/empty so UI can use demo mode.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool _ready = false;
  bool get isConnected => _ready && AppConfig.isSupabaseConfigured;

  static Future<void> init() async {
    if (!AppConfig.isSupabaseConfigured) {
      AppLogger.info('Supabase not configured — running with local demo data.');
      return;
    }
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        // Legacy anon JWT still accepted; prefer publishable when available.
        anonKey: AppConfig.supabaseAnonKey,
      );
      instance._ready = true;
      AppLogger.info('Supabase initialized.');
    } catch (e, s) {
      AppLogger.error('Supabase init failed', e, s);
    }
  }

  SupabaseClient get _c => Supabase.instance.client;

  Future<Empleado?> loginEmpleado({
    required String empresaCodigo,
    required String empleadoCodigo,
    required String pin,
  }) async {
    if (!isConnected) return null;
    try {
      final res = await _c.rpc('login_empleado', params: {
        'p_empresa_codigo': empresaCodigo,
        'p_empleado_codigo': empleadoCodigo,
        'p_pin': pin,
      });
      if (res == null) return null;
      final map = Map<String, dynamic>.from(res as Map);
      final empresa =
          Empresa.fromRow(Map<String, dynamic>.from(map['empresa'] as Map));
      return Empleado.fromRow(
        Map<String, dynamic>.from(map['empleado'] as Map),
        empresa,
      );
    } catch (e, s) {
      AppLogger.error('loginEmpleado failed', e, s);
      rethrow;
    }
  }

  Future<AdminSession?> loginAdmin({
    required String empresaCodigo,
    required String usuario,
    required String pin,
  }) async {
    if (!isConnected) return null;
    try {
      final res = await _c.rpc('login_admin', params: {
        'p_empresa_codigo': empresaCodigo,
        'p_usuario': usuario,
        'p_pin': pin,
      });
      if (res == null) return null;
      final map = Map<String, dynamic>.from(res as Map);
      final empresa =
          Empresa.fromRow(Map<String, dynamic>.from(map['empresa'] as Map));
      return AdminSession.fromRow(
        Map<String, dynamic>.from(map['admin'] as Map),
        empresa,
      );
    } catch (e, s) {
      AppLogger.error('loginAdmin failed', e, s);
      rethrow;
    }
  }

  Future<Obra?> obraForEmpleado(String empleadoId, String empresaId) async {
    if (!isConnected) return null;
    try {
      final res = await _c.rpc('obra_for_empleado', params: {
        'p_empleado_id': empleadoId,
        'p_empresa_id': empresaId,
      });
      if (res == null) return null;
      return Obra.fromRow(Map<String, dynamic>.from(res as Map));
    } catch (e, s) {
      AppLogger.error('obraForEmpleado failed', e, s);
      return null;
    }
  }

  Future<List<Checada>> checadasByEmpleado(String empleadoId) async {
    if (!isConnected) return [];
    try {
      final rows = await _c.rpc('list_checadas_empleado', params: {
        'p_empleado_id': empleadoId,
        'p_limit': 40,
      });
      if (rows is! List) return [];
      return rows
          .map((r) => _checadaFromRow(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (e, s) {
      AppLogger.error('checadasByEmpleado failed', e, s);
      return [];
    }
  }

  Future<Checada?> registerChecada({
    required String empleadoId,
    String? obraId,
    required CheckadaType tipo,
    double? lat,
    double? lng,
    double? distanceMeters,
  }) async {
    if (!isConnected) return null;
    try {
      final res = await _c.rpc('register_checada', params: {
        'p_empleado_id': empleadoId,
        'p_obra_id': obraId,
        'p_tipo': tipo.name,
        'p_lat': lat,
        'p_lng': lng,
        'p_distancia_metros': distanceMeters,
      });
      if (res == null) return null;
      return _checadaFromRow(Map<String, dynamic>.from(res as Map));
    } catch (e, s) {
      AppLogger.error('registerChecada failed', e, s);
      rethrow;
    }
  }

  Future<DashboardData?> dashboard(String empresaId) async {
    if (!isConnected) return null;
    try {
      final res = await _c.rpc(
        'dashboard_empresa',
        params: {'p_empresa_id': empresaId},
      );
      if (res == null) return null;
      final m = Map<String, dynamic>.from(res as Map);
      return DashboardData(
        empleados: (m['empleados'] as num?)?.toInt() ?? 0,
        entradas: (m['entradas'] as num?)?.toInt() ?? 0,
        salidas: (m['salidas'] as num?)?.toInt() ?? 0,
        obrasActivas: (m['obras_activas'] as num?)?.toInt() ?? 0,
        presentes: (m['presentes'] as num?)?.toInt() ?? 0,
        faltas: (m['faltas'] as num?)?.toInt() ?? 0,
        checadasHoy: (m['checadas_hoy'] as num?)?.toInt() ?? 0,
      );
    } catch (e, s) {
      AppLogger.error('dashboard failed', e, s);
      return null;
    }
  }

  Future<List<Empleado>> faltasHoy(Empresa empresa) async {
    if (!isConnected) return [];
    try {
      final rows = await _c.rpc(
        'faltas_hoy',
        params: {'p_empresa_id': empresa.id},
      );
      if (rows is! List) return [];
      return rows
          .map((r) => Empleado.fromRow(
                Map<String, dynamic>.from(r as Map),
                empresa,
              ))
          .toList();
    } catch (e, s) {
      AppLogger.error('faltasHoy failed', e, s);
      return [];
    }
  }

  Checada _checadaFromRow(Map<String, dynamic> r) {
    final ts = DateTime.tryParse('${r['registrado_at']}')?.toLocal() ??
        DateTime.now();
    return Checada(
      id: '${r['id']}',
      employeeId: '${r['empleado_id']}',
      obraId: '${r['obra_id'] ?? ''}',
      type: '${r['tipo']}' == 'salida'
          ? CheckadaType.salida
          : CheckadaType.entrada,
      status: CheckadaStatus.verified,
      timestamp: ts,
      latitude: (r['lat'] as num?)?.toDouble(),
      longitude: (r['lng'] as num?)?.toDouble(),
      distance: (r['distancia_metros'] as num?)?.toDouble(),
      biometricVerified: false,
      createdAt: ts,
    );
  }
}
