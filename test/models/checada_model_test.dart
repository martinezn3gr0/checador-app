import 'package:checador_express/models/checada_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses check data from RPC payload', () {
    final checada = Checada.fromJson({
      'id': 'check-1',
      'employee_id': 'employee-1',
      'obra_id': 'obra-1',
      'type': 'salida',
      'status': 'verificada',
      'timestamp': '2026-07-22T11:00:00Z',
      'latitude': 19.4326,
      'longitude': -99.1332,
      'distance_meters': 74.5,
      'photo_url': null,
      'biometric_verified': true,
      'notes': 'Dentro del radio',
      'created_at': '2026-07-22T11:00:01Z',
    });

    expect(checada.type, ChecadaType.salida);
    expect(checada.status, ChecadaStatus.verified);
    expect(checada.distance, 74.5);
    expect(checada.biometricVerified, isTrue);
  });
}
