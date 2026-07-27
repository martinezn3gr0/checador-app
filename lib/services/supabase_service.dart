import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/checada_model.dart';
import '../models/entities.dart';
import '../utils/logger.dart';

/// Data layer over the real Supabase schema (Spanish columns + UUIDs).
///
/// Tables: empresas, empleados, administradores, obras, empleado_obras, checadas.
/// When Supabase is not configured the methods return null/empty so the UI can
/// fall back to a local demo experience.
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
        anonKey: AppConfig.supabaseAnonKey,
      );
      instance._ready = true;
      AppLogger.info('Supabase initialized.');
    } catch (e, s) {
      AppLogger.error('Supabase init failed', e, s);
    }
  }

  SupabaseClient get _c => Supabase.instance.client;

  Future<Empresa?> _empresaByCodigo(String codigo) async {
    final row = await _c
        .from('empresas')
        .select()
        .eq('codigo', codigo)
        .eq('activa', true)
        .maybeSingle();
    return row == null ? null : Empresa.fromRow(row);
  }

  /// Employee login by empresa code + employee code + pin.
  Future<Empleado?> loginEmpleado({
    required String empresaCodigo,
    required String empleadoCodigo,
    required String pin,
  }) async {
    if (!isConnected) return null;
    try {
      final empresa = await _empresaByCodigo(empresaCodigo);
      if (empresa == null) return null;
      final row = await _c
          .from('empleados')
          .select()
          .eq('empresa_id', empresa.id)
          .eq('codigo', empleadoCodigo)
          .eq('pin', pin)
          .eq('activo', true)
          .maybeSingle();
      return row == null ? null : Empleado.fromRow(row, empresa);
    } catch (e, s) {
      AppLogger.error('loginEmpleado failed', e, s);
      rethrow;
    }
  }

  /// Admin login by empresa code + usuario + pin.
  Future<AdminSession?> loginAdmin({
    required String empresaCodigo,
    required String usuario,
    required String pin,
  }) async {
    if (!isConnected) return null;
    try {
      final empresa = await _empresaByCodigo(empresaCodigo);
      if (empresa == null) return null;
      final row = await _c
          .from('administradores')
          .select()
          .eq('empresa_id', empresa.id)
          .eq('usuario', usuario)
          .eq('pin', pin)
          .eq('activo', true)
          .maybeSingle();
      return row == null ? null : AdminSession.fromRow(row, empresa);
    } catch (e, s) {
      AppLogger.error('loginAdmin failed', e, s);
      rethrow;
    }
  }

  /// The obra assigned to an employee (via empleado_obras), else first obra.
  Future<Obra?> obraForEmpleado(String empleadoId, String empresaId) async {
    if (!isConnected) return null;
    try {
      final link = await _c
          .from('empleado_obras')
          .select('obra_id, obras(*)')
          .eq('empleado_id', empleadoId)
          .maybeSingle();
      if (link != null && link['obras'] != null) {
        return Obra.fromRow(Map<String, dynamic>.from(link['obras']));
      }
      final first = await _c
          .from('obras')
          .select()
          .eq('empresa_id', empresaId)
          .eq('activa', true)
          .limit(1)
          .maybeSingle();
      return first == null ? null : Obra.fromRow(first);
    } catch (e, s) {
      AppLogger.error('obraForEmpleado failed', e, s);
      return null;
    }
  }

  Future<List<Checada>> checadasByEmpleado(String empleadoId) async {
    if (!isConnected) return [];
    try {
      final rows = await _c
          .from('checadas')
          .select()
          .eq('empleado_id', empleadoId)
          .order('registrado_at', ascending: false)
          .limit(30);
      return rows.map<Checada>(_checadaFromRow).toList();
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
  }) async {
    if (!isConnected) return null;
    try {
      final now = DateTime.now();
      final rows = await _c.from('checadas').insert({
        'empleado_id': empleadoId,
        'obra_id': obraId,
        'tipo': tipo.name,
        'registrado_at': now.toIso8601String(),
        'FECHA': now.toIso8601String().substring(0, 10),
        'lat': lat,
        'lng': lng,
      }).select();
      if (rows.isEmpty) return null;
      return _checadaFromRow(rows.first);
    } catch (e, s) {
      AppLogger.error('registerChecada failed', e, s);
      rethrow;
    }
  }

  /// Aggregated dashboard metrics for an empresa.
  Future<DashboardData?> dashboard(String empresaId) async {
    if (!isConnected) return null;
    try {
      final empleados = await _c
          .from('empleados')
          .select('id')
          .eq('empresa_id', empresaId)
          .eq('activo', true);
      final ids = empleados.map((e) => '${e['id']}').toList();

      final obras = await _c
          .from('obras')
          .select('id')
          .eq('empresa_id', empresaId)
          .eq('activa', true);

      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day)
          .toUtc()
          .toIso8601String();

      List<Map<String, dynamic>> checadasHoy = [];
      if (ids.isNotEmpty) {
        checadasHoy = List<Map<String, dynamic>>.from(await _c
            .from('checadas')
            .select('empleado_id, tipo, registrado_at')
            .inFilter('empleado_id', ids)
            .gte('registrado_at', start));
      }

      final entradas =
          checadasHoy.where((c) => c['tipo'] == 'entrada').length;
      final salidas = checadasHoy.where((c) => c['tipo'] == 'salida').length;
      final presentesSet =
          checadasHoy.map((c) => '${c['empleado_id']}').toSet();

      return DashboardData(
        empleados: ids.length,
        entradas: entradas,
        salidas: salidas,
        obrasActivas: obras.length,
        presentes: presentesSet.length,
        faltas: ids.length - presentesSet.length,
        checadasHoy: checadasHoy.length,
      );
    } catch (e, s) {
      AppLogger.error('dashboard failed', e, s);
      return null;
    }
  }

  /// Employees without any checada today (faltas).
  Future<List<Empleado>> faltasHoy(Empresa empresa) async {
    if (!isConnected) return [];
    try {
      final empleadosRows = await _c
          .from('empleados')
          .select()
          .eq('empresa_id', empresa.id)
          .eq('activo', true);
      final ids = empleadosRows.map((e) => '${e['id']}').toList();
      if (ids.isEmpty) return [];

      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day)
          .toUtc()
          .toIso8601String();
      final checadasHoy = await _c
          .from('checadas')
          .select('empleado_id')
          .inFilter('empleado_id', ids)
          .gte('registrado_at', start);
      final presentes =
          checadasHoy.map((c) => '${c['empleado_id']}').toSet();

      return empleadosRows
          .where((e) => !presentes.contains('${e['id']}'))
          .map((e) => Empleado.fromRow(e, empresa))
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
      biometricVerified: false,
      createdAt: ts,
    );
  }
}
