import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';

class SupabaseService {
  SupabaseClient get client {
    if (!AppConfig.hasSupabaseConfig) {
      throw StateError(
        'Supabase is not configured. Provide SUPABASE_URL and '
        'SUPABASE_ANON_KEY with --dart-define.',
      );
    }

    return Supabase.instance.client;
  }

  Future<dynamic> callRpc(
    String functionName, {
    Map<String, dynamic> params = const {},
  }) {
    return client.rpc(functionName, params: params);
  }
}
