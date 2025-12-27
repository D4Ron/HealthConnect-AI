import "package:supabase_flutter/supabase_flutter.dart";

class SupabaseConfig {
  // TODO: Replace with your actual Supabase credentials from the email
  static const String supabaseUrl = 'https://oszwyjfqxpkuijmfojni.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_cMyo-uEXyhHjYWImHP1P7w_IeS5hvi0';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}