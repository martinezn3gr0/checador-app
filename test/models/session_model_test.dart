import 'package:checador_express/models/session_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes and restores an admin session', () {
    final session = AppSession(
      userId: 'user-1',
      userCode: 'MEI001',
      accessToken: 'token',
      role: UserRole.admin,
      companyId: 'company-1',
      createdAt: DateTime.utc(2026, 7, 22),
    );

    final restored = AppSession.fromJson(session.toJson());

    expect(restored.userId, session.userId);
    expect(restored.userCode, session.userCode);
    expect(restored.role, UserRole.admin);
    expect(restored.companyId, session.companyId);
  });

  test('accepts Spanish role names', () {
    expect(UserRoleX.fromString('administrador'), UserRole.admin);
    expect(UserRoleX.fromString('empleado'), UserRole.employee);
  });
}
