import 'package:flutter_test/flutter_test.dart';
import 'package:checador_express/models/entities.dart';

void main() {
  group('Empresa/Empleado/Obra', () {
    test('Empresa.fromRow maps fields', () {
      final e = Empresa.fromRow({
        'id': 'e1',
        'codigo': 'INST01',
        'nombre': 'Instalec J',
      });
      expect(e.id, 'e1');
      expect(e.codigo, 'INST01');
      expect(e.nombre, 'Instalec J');
    });

    test('Obra.fromRow defaults radio and detects location', () {
      final o = Obra.fromRow({
        'id': 'o1',
        'nombre': 'Casa',
        'lat': 19.4,
        'lng': -99.1,
      });
      expect(o.hasLocation, isTrue);
      expect(o.radioMetros, 100);
    });

    test('DashboardData asistencia percentage', () {
      const d = DashboardData(
        empleados: 10,
        entradas: 8,
        salidas: 4,
        obrasActivas: 2,
        presentes: 8,
        faltas: 2,
        checadasHoy: 12,
      );
      expect(d.asistencia, 80);
    });
  });
}
