import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../screens/employee/employee_login_screen.dart';

/// Standalone Employee application (Checador Empleado).
class EmployeeApp extends StatelessWidget {
  const EmployeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checador Empleado',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const EmployeeLoginScreen(),
    );
  }
}
