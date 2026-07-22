import 'package:flutter_test/flutter_test.dart';
import 'package:checador_express/models/checada_model.dart';

void main() {
  group('Checada', () {
    final base = Checada(
      id: '1',
      employeeId: 'emp-1',
      obraId: 'obra-1',
      type: CheckadaType.entrada,
      status: CheckadaStatus.pending,
      timestamp: DateTime(2026, 1, 1, 8, 0),
      biometricVerified: false,
      createdAt: DateTime(2026, 1, 1, 8, 0),
    );

    test('stores provided values', () {
      expect(base.id, '1');
      expect(base.type, CheckadaType.entrada);
      expect(base.status, CheckadaStatus.pending);
      expect(base.biometricVerified, isFalse);
    });

    test('copyWith overrides only provided fields', () {
      final updated = base.copyWith(
        status: CheckadaStatus.verified,
        biometricVerified: true,
      );

      expect(updated.status, CheckadaStatus.verified);
      expect(updated.biometricVerified, isTrue);
      expect(updated.id, base.id);
      expect(updated.employeeId, base.employeeId);
      expect(updated.type, base.type);
    });
  });
}
