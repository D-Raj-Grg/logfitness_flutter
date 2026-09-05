import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A [LocalStorage] implementation backed by the platform keychain /
/// keystore via `flutter_secure_storage`.
///
/// `supabase_flutter`'s default local storage keeps the persisted session
/// (including the refresh token) in `SharedPreferences`, which is plain
/// text on disk. This app instead keeps the refresh token at rest in the
/// secure enclave, per PLANNING.md §2 ("Session").
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage({
    FlutterSecureStorage? secureStorage,
    this.persistSessionKey = _defaultKey,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _defaultKey = 'supabase.session';

  final FlutterSecureStorage _secureStorage;

  /// The key the session blob is stored under.
  final String persistSessionKey;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() =>
      _secureStorage.containsKey(key: persistSessionKey);

  @override
  Future<String?> accessToken() =>
      _secureStorage.read(key: persistSessionKey);

  @override
  Future<void> removePersistedSession() =>
      _secureStorage.delete(key: persistSessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _secureStorage.write(
        key: persistSessionKey,
        value: persistSessionString,
      );
}
