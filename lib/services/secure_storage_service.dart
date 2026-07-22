import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

class SecureStorageService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserCode = 'user_code';
  static const String _keyAccessToken = 'access_token';
  static const String _keyUserRole = 'user_role';
  
  final FlutterSecureStorage _storage;
  
  SecureStorageService(this._storage);
  
  /// Guarda las credenciales de sesión
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
      ]);
      AppLogger.info('Session saved securely');
    } catch (e) {
      AppLogger.error('Error saving session', e);
      rethrow;
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
      ]);
      AppLogger.info('Session cleared');
    } catch (e) {
      AppLogger.error('Error clearing session', e);
      rethrow;
    }
  }
}
