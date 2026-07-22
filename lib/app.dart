import 'package:flutter/material.dart';

import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/presentation/admin_shell_page.dart';
import 'features/admin/presentation/employees_page.dart';
import 'features/admin/presentation/obras_page.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/startup_page.dart';
import 'features/employee/presentation/employee_shell_page.dart';

class ChecadorExpressApp extends StatelessWidget {
  const ChecadorExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checador Express',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.startup,
      onGenerateRoute: (settings) {
        final page = switch (settings.name) {
          AppRoutes.startup => const StartupPage(),
          AppRoutes.login => const LoginPage(),
          AppRoutes.adminHome => const AdminShellPage(),
          AppRoutes.adminEmployees => EmployeesPage(
              filters: _argumentsAsMap(settings.arguments),
            ),
          AppRoutes.adminObras => const ObrasPage(),
          AppRoutes.employeeHome => const EmployeeShellPage(),
          _ => const StartupPage(),
        };

        return MaterialPageRoute<void>(
          builder: (_) => page,
          settings: settings,
        );
      },
    );
  }

  Map<String, dynamic> _argumentsAsMap(Object? arguments) {
    if (arguments is Map<String, dynamic>) {
      return arguments;
    }

    return const {};
  }
}
