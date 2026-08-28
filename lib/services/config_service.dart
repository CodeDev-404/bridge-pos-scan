import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const _urlKey = 'supabase_url';
  static const _keyKey = 'supabase_anon_key';

  static const String defaultUrl = 'YOUR_SUPABASE_URL';
  static const String defaultKey = 'YOUR_SUPABASE_ANON_KEY';

  Future<void> saveConfig(String url, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, url);
    await prefs.setString(_keyKey, key);
  }

  Future<String> getUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_urlKey) ?? defaultUrl;
  }

  Future<String> getKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyKey) ?? defaultKey;
  }

  Future<bool> hasCustomConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_urlKey) && prefs.containsKey(_keyKey);
  }

  Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_urlKey);
    await prefs.remove(_keyKey);
  }
}