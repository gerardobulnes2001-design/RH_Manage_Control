import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _keyUrl = 'supabase_project_url';
  static const String _keyAnonKey = 'supabase_anon_key';

  // Valores por defecto o inyectados por --dart-define
  static const String defaultUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xyzcompany.supabase.co',
  );

  static const String defaultAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy',
  );

  static Future<String> getUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUrl) ?? defaultUrl;
  }

  static Future<String> getAnonKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAnonKey) ?? defaultAnonKey;
  }

  static Future<void> saveCredentials(String url, String anonKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUrl, url.trim());
    await prefs.setString(_keyAnonKey, anonKey.trim());
  }

  static bool isConfigured(String url, String anonKey) {
    return url.isNotEmpty &&
        url.startsWith('https://') &&
        !url.contains('xyzcompany') &&
        anonKey.isNotEmpty &&
        !anonKey.contains('dummy');
  }

  static Future<bool> initializeClient() async {
    try {
      final url = await getUrl();
      final key = await getAnonKey();

      if (!isConfigured(url, key)) {
        return false;
      }

      await Supabase.initialize(
        url: url,
        anonKey: key,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
