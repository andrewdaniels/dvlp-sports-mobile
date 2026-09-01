import 'package:supabase_flutter/supabase_flutter.dart';

import '../env/env.dart';

/// Wraps Supabase client initialization.
///
/// Call [init] once from `main.dart` before `runApp`.
/// Access the client via [Supabase.instance.client] anywhere.
class SupabaseService {
  SupabaseService._();

  static Future<void> init() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
