import 'package:flutter/material.dart';

import 'apps/employee_app.dart';
import 'config/app_config.dart';
import 'config/env_stub.dart'
    if (dart.library.io) 'config/env_io.dart' as env;
import 'services/supabase_service.dart';

/// Entry point for the standalone Employee app.
/// Build: flutter build apk --flavor empleado -t lib/main_empleado.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.bootstrapFromPlatformEnvironment(env.readPlatformEnvironment());
  await SupabaseService.init();
  runApp(const EmployeeApp());
}
