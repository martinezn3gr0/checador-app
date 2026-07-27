import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../screens/admin/admin_landing_screen.dart';

/// Standalone Admin application (Checador Admin).
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checador Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AdminLandingScreen(),
    );
  }
}
