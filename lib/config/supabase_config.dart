import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Supabase Configuration
/// 
/// SETUP INSTRUCTIONS:
/// 1. Go to https://supabase.com and create a new project
/// 2. Copy your project URL and anon key from Settings > API
/// 3. Add them to your secrets.json file:
///    {
///      "SUPABASE_URL": "https://your-project.supabase.co",
///      "SUPABASE_ANON_KEY": "your-anon-key"
///    }
/// 4. Run the SQL schema from supabase_complete_schema.sql in SQL Editor
/// 5. Enable Email Auth in Authentication > Providers

class SupabaseConfig {
  static const String _urlKey = 'SUPABASE_URL';
  static const String _anonKeyKey = 'SUPABASE_ANON_KEY';

  /// Initialize Supabase with credentials from environment/secrets
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        // Auto-refresh tokens
        autoRefreshToken: true,
        // Persist session across app restarts
        persistSession: true,
        // Use secure storage for tokens
        localStorage: const SecureLocalStorage(),
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
      storageOptions: const StorageClientOptions(
        retryAttempts: 3,
      ),
    );

    if (kDebugMode) {
      print('[Supabase] Initialized successfully');
      print('[Supabase] URL: $supabaseUrl');
    }
  }

  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Check if user is authenticated
  static bool get isAuthenticated => client.auth.currentUser != null;

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Get current user ID
  static String? get currentUserId => client.auth.currentUser?.id;
}

/// Secure storage implementation for Supabase auth tokens
class SecureLocalStorage extends LocalStorage {
  const SecureLocalStorage();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  @override
  Future<void> initialize() async {
    // No initialization needed
  }

  @override
  Future<String?> accessToken() async {
    return await _storage.read(key: 'supabase.auth.token');
  }

  @override
  Future<bool> hasAccessToken() async {
    final token = await accessToken();
    return token != null;
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(
      key: 'supabase.auth.token',
      value: persistSessionString,
    );
  }

  @override
  Future<void> removePersistedSession() async {
    await _storage.delete(key: 'supabase.auth.token');
  }
}
