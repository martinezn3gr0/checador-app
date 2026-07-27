import 'package:flutter/material.dart';

import 'apps/employee_app.dart';
import 'services/supabase_service.dart';

/// Entry point for the standalone Employee app.
/// Build: flutter build apk --flavor empleado -t lib/main_empleado.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const EmployeeApp());
}
