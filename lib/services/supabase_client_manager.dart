import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseClientManager {
  SupabaseClient? _client;
  String? _currentUrl;
  String? _currentKey;

  SupabaseClientManager._internal();
  static final SupabaseClientManager _instance = SupabaseClientManager._internal();
  factory SupabaseClientManager() => _instance;

  SupabaseClient? get client => _client;

  bool get isInitialized => _client != null;

  /// Initialize with default or saved config
  Future<void> initialize() async {
    final url = SupabaseConfig.supabaseUrl;
    final key = SupabaseConfig.supabaseAnonKey;
    await _createClient(url, key);
  }

  /// Create new client and replace current
  Future<void> _createClient(String url, String key) async {
    try {
      final client = SupabaseClient(url, key);
      
      // Test connection
      await client.from(SupabaseConfig.productsTable).select('id').limit(1);
      
      _client = client;
      _currentUrl = url;
      _currentKey = key;
    } catch (e) {
      throw Exception('Failed to create Supabase client: $e');
    }
  }

  /// Hot-swap to new credentials (no restart needed)
  Future<void> switchCredentials(String url, String key) async {
    if (url == _currentUrl && key == _currentKey) return;
    
    await _createClient(url, key);
    
    // Update stored config
    await SupabaseConfig.updateConfig(url, key);
  }

  /// Reset to defaults
  Future<void> reset() async {
    await SupabaseConfig.resetToDefault();
    await initialize();
  }

  /// Get current credentials
  String? get currentUrl => _currentUrl;
  String? get currentKey => _currentKey;
  
  /// Force re-test current connection
  Future<bool> testConnection() async {
    if (_client == null) return false;
    try {
      await _client!.from(SupabaseConfig.productsTable).select('id').limit(1).timeout(const Duration(seconds: 3));
      return true;
    } catch (_) {
      return false;
    }
  }
}