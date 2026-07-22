import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/session_model.dart';
import '../../services/attendance_rpc_service.dart';
import '../../services/auth_rpc_service.dart';
import '../../services/employee_rpc_service.dart';
import '../../services/location_service.dart';
import '../../services/secure_storage_service.dart';
import '../../services/supabase_service.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final authServiceProvider = Provider<AuthRpcService>((ref) {
  return AuthRpcService(
    ref.watch(supabaseServiceProvider),
    ref.watch(secureStorageProvider),
  );
});

final employeeServiceProvider = Provider<EmployeeRpcService>((ref) {
  return EmployeeRpcService(ref.watch(supabaseServiceProvider));
});

final attendanceServiceProvider = Provider<AttendanceRpcService>((ref) {
  return AttendanceRpcService(ref.watch(supabaseServiceProvider));
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final currentSessionProvider =
    StateNotifierProvider<SessionController, AsyncValue<AppSession?>>((ref) {
  return SessionController(ref.watch(authServiceProvider));
});

class SessionController extends StateNotifier<AsyncValue<AppSession?>> {
  final AuthRpcService _authService;

  SessionController(this._authService) : super(const AsyncLoading()) {
    restore();
  }

  Future<void> restore() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _authService.restoreSession());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> login({
    required String companyCode,
    required String userCode,
    required String pin,
    required UserRole role,
  }) async {
    state = const AsyncLoading();
    try {
      final session = await _authService.loginWithCodeAndPin(
        companyCode: companyCode,
        userCode: userCode,
        pin: pin,
        expectedRole: role,
      );
      state = AsyncData(session);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncData(null);
  }
}
