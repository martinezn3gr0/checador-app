import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'config/env_stub.dart'
    if (dart.library.io) 'config/env_io.dart' as env;
import 'screens/role_select_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

/// Combined launcher used for web preview. Shipped products use
/// `main_empleado.dart` and `main_admin.dart`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.bootstrapFromPlatformEnvironment(env.readPlatformEnvironment());
  await SupabaseService.init();
  runApp(const CheckadorExpressApp());
}

class CheckadorExpressApp extends StatelessWidget {
  const CheckadorExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checador Express',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const RoleSelectScreen(),
    );
  }
}
