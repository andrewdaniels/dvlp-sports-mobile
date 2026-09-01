import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? _missing('SUPABASE_URL');
  static String get supabasePublishableKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? _missing('SUPABASE_PUBLISHABLE_KEY');

  static String _missing(String key) {
    throw StateError('Missing env var: $key. Check mobile/.env');
  }
}
