import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/entities.dart';
import '../utils/logger.dart';
import 'secure_storage_service.dart';

/// Persists lightweight session metadata between launches.
class SessionService {
  SessionService._(this._storage);

  static final SessionService instance =
      SessionService._(SecureStorageService(const FlutterSecureStorage()));

  final SecureStorageService _storage;

  static const _roleEmployee = 'empleado';
  static const _roleAdmin = 'admin';

  Future<void> saveEmployee(Empleado empleado) async {
    await _storage.saveSession(
      userId: empleado.id,
      userCode: empleado.codigo,
      accessToken: empleado.empresa.id,
      userRole: _roleEmployee,
    );
    AppLogger.info('Employee session saved');
  }

  Future<void> saveAdmin(AdminSession admin) async {
    await _storage.saveSession(
      userId: admin.id,
      userCode: admin.usuario,
      accessToken: admin.empresa.id,
      userRole: _roleAdmin,
    );
    AppLogger.info('Admin session saved');
  }

  Future<bool> hasSession() => _storage.hasSession();

  Future<String?> role() => _storage.getUserRole();

  Future<void> clear() => _storage.clearSession();
}
