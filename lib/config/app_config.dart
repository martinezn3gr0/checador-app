/// Runtime configuration, populated at build time via --dart-define.
///
/// Example:
///   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=eyJ...
class AppConfig {
  AppConfig._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// True only when both Supabase values were provided at build time.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // Geofence defaults for the check-in map (obra location + allowed radius).
  static const double obraLat = 19.4326; // CDMX centro (demo)
  static const double obraLng = -99.1332;
  static const double geofenceRadiusMeters = 150;
}
