/// Runtime configuration.
///
/// Prefer `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.
/// Local Cloud Agents may also inject `SUPABASE_*` env vars at process start;
/// those are read once via [bootstrapFromPlatformEnvironment] before `runApp`.
class AppConfig {
  AppConfig._();

  static String _supabaseUrl =
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static String _supabaseAnonKey =
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static String get supabaseUrl => _supabaseUrl;
  static String get supabaseAnonKey => _supabaseAnonKey;

  /// True only when both Supabase values are available.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Fill empty dart-defines from process environment (Cloud Agent secrets).
  static void bootstrapFromPlatformEnvironment(
    Map<String, String> environment,
  ) {
    if (_supabaseUrl.isEmpty) {
      _supabaseUrl = environment['SUPABASE_URL'] ?? '';
    }
    if (_supabaseAnonKey.isEmpty) {
      _supabaseAnonKey = environment['SUPABASE_ANON_KEY'] ?? '';
    }
  }

  /// Demo geofence defaults (CDMX) when an obra has no coordinates.
  static const double obraLat = 19.4326;
  static const double obraLng = -99.1332;
  static const double geofenceRadiusMeters = 150;
}
