import '../models/session_model.dart';
import 'secure_storage_service.dart';
import 'supabase_service.dart';

class AuthRpcService {
  final SupabaseService _supabaseService;
  final SecureStorageService _storageService;

  AuthRpcService(this._supabaseService, this._storageService);

  Future<AppSession> loginWithCodeAndPin({
    required String companyCode,
    required String userCode,
    required String pin,
    required UserRole expectedRole,
  }) async {
    final response = await _supabaseService.callRpc(
      'auth_login_with_code_pin',
      params: {
        'p_company_code': companyCode.trim(),
        'p_user_code': userCode.trim(),
        'p_pin': pin,
        'p_expected_role': expectedRole.value,
      },
    );

    final payload = _extractPayload(response);
    final session = AppSession.fromJson(payload);
    await _storageService.saveAppSession(session);
    return session;
  }

  Future<AppSession?> restoreSession() {
    return _storageService.getSession();
  }

  Future<void> logout() {
    return _storageService.clearSession();
  }

  Map<String, dynamic> _extractPayload(dynamic response) {
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    if (response is List && response.isNotEmpty) {
      final first = response.first;
      if (first is Map) {
        return Map<String, dynamic>.from(first);
      }
    }

    throw StateError('Unexpected auth RPC response: $response');
  }
}
