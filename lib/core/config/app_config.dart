enum AppFlavor { admin, employee, unified }

class AppConfig {
  AppConfig._();

  static const String appName = 'Checador Express';
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const String flavorValue = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'unified',
  );

  static AppFlavor get flavor {
    switch (flavorValue.toLowerCase()) {
      case 'admin':
        return AppFlavor.admin;
      case 'employee':
      case 'empleado':
        return AppFlavor.employee;
      default:
        return AppFlavor.unified;
    }
  }

  static bool get hasSupabaseConfig {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}
