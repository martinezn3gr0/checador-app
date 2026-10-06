/// Runtime configuration for Checador Express ↔ Supabase.
///
/// Resolution order for credentials:
/// 1. `--dart-define=SUPABASE_URL` / `SUPABASE_ANON_KEY`
/// 2. Process env (`SUPABASE_*`), only when the URL matches [projectRef]
/// 3. Built-in defaults for project `checador-express` (anon key is public)
///
/// Stale Cloud Agent secrets pointing at a different project are ignored so
/// the app stays connected to the canonical backend.
class AppConfig {
  AppConfig._();

  /// Canonical Supabase project for this app.
  static const String projectRef = 'welyvwhjtwsvzyobewzx';
  static const String projectName = 'checador-express';

  static const String defaultUrl = 'https://$projectRef.supabase.co';

  /// Legacy anon JWT (public client key). Protected by RLS + SECURITY DEFINER RPCs.
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndlbHl2d2hqdHdzdnp5b2Jld3p4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA3Nzc1MzUsImV4cCI6MjEwNjM1MzUzNX0.hxNx5RasEnQq_hoW6x6EQ551Lt-mrc6UefoiZr3bBCk';

  static String _supabaseUrl =
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static String _supabaseAnonKey =
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// True when URL/key came from `--dart-define` (not env / defaults).
  static final bool _urlFromDefine = _supabaseUrl.isNotEmpty;
  static final bool _keyFromDefine = _supabaseAnonKey.isNotEmpty;

  static String get supabaseUrl =>
      _supabaseUrl.isEmpty ? defaultUrl : _supabaseUrl;
  static String get supabaseAnonKey =>
      _supabaseAnonKey.isEmpty ? defaultAnonKey : _supabaseAnonKey;

  /// Always true once defaults are applied; kept for call-site clarity.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Whether [supabaseUrl] targets the canonical project.
  static bool get isCanonicalProject => supabaseUrl.contains(projectRef);

  /// Fill empty dart-defines from process environment (Cloud Agent secrets).
  ///
  /// Ignores env values whose URL does not contain [projectRef], so outdated
  /// secrets cannot silently point the app at the wrong Supabase project.
  static void bootstrapFromPlatformEnvironment(
    Map<String, String> environment,
  ) {
    final envUrl = (environment['SUPABASE_URL'] ?? '').trim();
    final envKey = (environment['SUPABASE_ANON_KEY'] ?? '').trim();
    final envMatchesProject = envUrl.contains(projectRef);

    if (!_urlFromDefine) {
      _supabaseUrl = envMatchesProject ? envUrl : defaultUrl;
    }

    if (!_keyFromDefine) {
      _supabaseAnonKey =
          envMatchesProject && envKey.isNotEmpty ? envKey : defaultAnonKey;
    }
  }

  /// Test-only: restore defaults as if no dart-defines / env were applied.
  static void debugResetToDefaults() {
    if (_urlFromDefine || _keyFromDefine) return;
    _supabaseUrl = defaultUrl;
    _supabaseAnonKey = defaultAnonKey;
  }

  /// Demo geofence defaults (CDMX) when an obra has no coordinates.
  static const double obraLat = 19.4326;
  static const double obraLng = -99.1332;
  static const double geofenceRadiusMeters = 150;
}
