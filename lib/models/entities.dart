/// Lightweight domain models mapped to the real Supabase schema.
library;

class Empresa {
  final String id;
  final String codigo;
  final String nombre;

  const Empresa({required this.id, required this.codigo, required this.nombre});

  factory Empresa.fromRow(Map<String, dynamic> r) => Empresa(
        id: '${r['id']}',
        codigo: '${r['codigo'] ?? ''}',
        nombre: '${r['nombre'] ?? ''}',
      );
}

class Empleado {
  final String id;
  final String codigo;
  final String nombre;
  final String departamento;
  final Empresa empresa;

  const Empleado({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.departamento,
    required this.empresa,
  });

  factory Empleado.fromRow(Map<String, dynamic> r, Empresa empresa) => Empleado(
        id: '${r['id']}',
        codigo: '${r['codigo'] ?? ''}',
        nombre: '${r['nombre'] ?? ''}',
        departamento: '${r['departamento'] ?? ''}',
        empresa: empresa,
      );
}

class AdminSession {
  final String id;
  final String usuario;
  final String nombre;
  final Empresa empresa;

  const AdminSession({
    required this.id,
    required this.usuario,
    required this.nombre,
    required this.empresa,
  });

  factory AdminSession.fromRow(Map<String, dynamic> r, Empresa empresa) =>
      AdminSession(
        id: '${r['id']}',
        usuario: '${r['usuario'] ?? ''}',
        nombre: '${r['nombre'] ?? ''}',
        empresa: empresa,
      );
}

class Obra {
  final String id;
  final String nombre;
  final double? lat;
  final double? lng;
  final int radioMetros;

  const Obra({
    required this.id,
    required this.nombre,
    this.lat,
    this.lng,
    required this.radioMetros,
  });

  bool get hasLocation => lat != null && lng != null;

  factory Obra.fromRow(Map<String, dynamic> r) => Obra(
        id: '${r['id']}',
        nombre: '${r['nombre'] ?? ''}',
        lat: (r['lat'] as num?)?.toDouble(),
        lng: (r['lng'] as num?)?.toDouble(),
        radioMetros: (r['radio_metros'] as num?)?.toInt() ?? 100,
      );
}

class DashboardData {
  final int empleados;
  final int entradas;
  final int salidas;
  final int obrasActivas;
  final int presentes;
  final int faltas;
  final int checadasHoy;

  const DashboardData({
    required this.empleados,
    required this.entradas,
    required this.salidas,
    required this.obrasActivas,
    required this.presentes,
    required this.faltas,
    required this.checadasHoy,
  });

  double get asistencia => empleados == 0 ? 0 : (presentes / empleados) * 100;
}
