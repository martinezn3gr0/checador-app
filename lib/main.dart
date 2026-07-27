import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/role_select_screen.dart';
import 'services/supabase_service.dart';

/// Combined launcher used for web preview only. The shipped products are the
/// two standalone apps: `main_empleado.dart` and `main_admin.dart`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
