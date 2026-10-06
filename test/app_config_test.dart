import 'package:checador_express/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig.bootstrapFromPlatformEnvironment', () {
    setUp(AppConfig.debugResetToDefaults);

    test('falls back to checador-express when env is empty', () {
      AppConfig.bootstrapFromPlatformEnvironment(const {});
      expect(AppConfig.supabaseUrl, contains(AppConfig.projectRef));
      expect(AppConfig.supabaseAnonKey, isNotEmpty);
      expect(AppConfig.isCanonicalProject, isTrue);
      expect(AppConfig.isSupabaseConfigured, isTrue);
    });

    test('ignores stale secrets for a different project', () {
      // Synthetic wrong-project URL (not a live secret).
      const staleUrl =
          'https://otherprojectref000000000000.supabase.co'; // pragma: allowlist secret
      AppConfig.bootstrapFromPlatformEnvironment(const {
        'SUPABASE_URL': staleUrl,
        'SUPABASE_ANON_KEY': 'stale-anon-key',
      });
      expect(AppConfig.supabaseUrl, AppConfig.defaultUrl);
      expect(AppConfig.supabaseAnonKey, AppConfig.defaultAnonKey);
      expect(AppConfig.isCanonicalProject, isTrue);
    });

    test('accepts env secrets for the canonical project', () {
      const customKey = 'custom-canonical-anon-key';
      AppConfig.bootstrapFromPlatformEnvironment({
        'SUPABASE_URL': AppConfig.defaultUrl,
        'SUPABASE_ANON_KEY': customKey,
      });
      expect(AppConfig.supabaseUrl, AppConfig.defaultUrl);
      expect(AppConfig.supabaseAnonKey, customKey);
    });
  });
}
