import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/session_model.dart';
import '../utils/logger.dart';

class SecureStorageService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserCode = 'user_code';
  static const String _keyAccessToken = 'access_token';
  static const String _keyUserRole = 'user_role';
  static const String _keyCompanyId = 'company_id';
  static const String _keyCreatedAt = 'session_created_at';
  
  final FlutterSecureStorage _storage;
  
  SecureStorageService(this._storage);
  
  /// Guarda las credenciales de sesión.
  Future<void> saveSession({
    required String userId,
    required String userCode,
    required String accessToken,
    required String userRole,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _keyUserId, value: userId),
        _storage.write(key: _keyUserCode, value: userCode),
        _storage.write(key: _keyAccessToken, value: accessToken),
        _storage.write(key: _keyUserRole, value: userRole),
        _storage.write(
          key: _keyCreatedAt,
          value: DateTime.now().toIso8601String(),
        ),
      ]);
      AppLogger.info('Session saved securely');
    } catch (e) {
      AppLogger.error('Error saving session', e);
      rethrow;
    }
  }

  Future<void> saveAppSession(AppSession session) {
    return saveSession(
      userId: session.userId,
      userCode: session.userCode,
      accessToken: session.accessToken,
      userRole: session.role.value,
    ).then((_) {
      return _storage.write(key: _keyCompanyId, value: session.companyId);
    });
  }

  Future<AppSession?> getSession() async {
    try {
      final values = await Future.wait([
        _storage.read(key: _keyUserId),
        _storage.read(key: _keyUserCode),
        _storage.read(key: _keyAccessToken),
        _storage.read(key: _keyUserRole),
        _storage.read(key: _keyCompanyId),
        _storage.read(key: _keyCreatedAt),
      ]);

      final userId = values[0];
      final userCode = values[1];
      final accessToken = values[2];
      final role = values[3];

      if (userId == null ||
          userCode == null ||
          accessToken == null ||
          role == null) {
        return null;
      }

      return AppSession(
        userId: userId,
        userCode: userCode,
        accessToken: accessToken,
        role: UserRoleX.fromString(role),
        companyId: values[4],
        createdAt: DateTime.tryParse(values[5] ?? '') ?? DateTime.now(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error restoring session', e, stackTrace);
      return null;
    }
  }
  
  /// Obtiene el ID del usuario guardado
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      AppLogger.error('Error reading user ID', e);
      return null;
    }
  }
  
  /// Obtiene el código del usuario guardado
  Future<String?> getUserCode() async {
    try {
      return await _storage.read(key: _keyUserCode);
    } catch (e) {
      AppLogger.error('Error reading user code', e);
      return null;
    }
  }
  
  /// Obtiene el token de acceso guardado
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _keyAccessToken);
    } catch (e) {
      AppLogger.error('Error reading access token', e);
      return null;
    }
  }
  
  /// Obtiene el rol del usuario guardado
  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: _keyUserRole);
    } catch (e) {
      AppLogger.error('Error reading user role', e);
      return null;
    }
  }
  
  /// Verifica si existe sesión guardada
  Future<bool> hasSession() async {
    try {
      final userId = await _storage.read(key: _keyUserId);
      return userId != null && userId.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error checking session', e);
      return false;
    }
  }
  
  /// Limpia la sesión guardada
  Future<void> clearSession() async {
    try {
      await Future.wait([
        _storage.delete(key: _keyUserId),
        _storage.delete(key: _keyUserCode),
        _storage.delete(key: _keyAccessToken),
        _storage.delete(key: _keyUserRole),
        _storage.delete(key: _keyCompanyId),
        _storage.delete(key: _keyCreatedAt),
      ]);
      AppLogger.info('Session cleared');
    } catch (e) {
      AppLogger.error('Error clearing session', e);
      rethrow;
    }
  }
}
