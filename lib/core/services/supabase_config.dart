import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const String projectId = 'psjlycjbaiacdzvtewvi';
  static const String supabaseUrl = 'https://$projectId.supabase.co';
  
  // Publishable Key (Anon Key) - safe to use in client code
  static const String supabaseAnonKey = 'sb_publishable_c1EhUj6faoPYiqy9vPucXg_m7pdb8pQ';
  
  // Secret Key (Service Role Key) - WARNING: Never expose this in production clients!
  // We keep it here as requested, but we will use the Anon Key for client operations.
  static const String supabaseSecretKey = 'sb_secret_EZyiJpK6VhOSRwx-KfpClQ_fubcnVWC';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
