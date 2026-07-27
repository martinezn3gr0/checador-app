import 'package:flutter/material.dart';

import 'apps/admin_app.dart';
import 'services/supabase_service.dart';

/// Entry point for the standalone Admin app.
/// Build: flutter build apk --flavor admin -t lib/main_admin.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const AdminApp());
}
