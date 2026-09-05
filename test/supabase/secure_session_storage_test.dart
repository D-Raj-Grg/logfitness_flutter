// The refresh token at rest is the one Phase 1 decision with a security
// consequence (PLANNING.md §2), and it was shipped untested. These cover the
// contract supabase_flutter actually calls: it must round-trip through the
// secure store under one key, and clear completely on sign-out.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logfitness_flutter/supabase/secure_session_storage.dart';

class _InMemorySecureStorage implements FlutterSecureStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
      return;
    }
    values[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _InMemorySecureStorage secureStorage;
  late SecureSessionStorage storage;

  setUp(() {
    secureStorage = _InMemorySecureStorage();
    storage = SecureSessionStorage(secureStorage: secureStorage);
  });

  test('a persisted session round-trips through the secure store', () async {
    expect(await storage.hasAccessToken(), isFalse);

    await storage.persistSession('{"refresh_token":"rt-1"}');

    expect(await storage.hasAccessToken(), isTrue);
    expect(await storage.accessToken(), '{"refresh_token":"rt-1"}');
  });

  test('the session is written under exactly one key', () async {
    await storage.persistSession('{"refresh_token":"rt-1"}');

    expect(secureStorage.values.keys, hasLength(1));
    expect(secureStorage.values.keys.single, storage.persistSessionKey);
  });

  test('removing the session leaves nothing behind', () async {
    await storage.persistSession('{"refresh_token":"rt-1"}');
    await storage.removePersistedSession();

    expect(secureStorage.values, isEmpty);
    expect(await storage.hasAccessToken(), isFalse);
    expect(await storage.accessToken(), isNull);
  });

  test('a second sign-in overwrites the first account\'s session', () async {
    await storage.persistSession('{"refresh_token":"member"}');
    await storage.persistSession('{"refresh_token":"staff"}');

    expect(secureStorage.values.values.single, '{"refresh_token":"staff"}');
  });
}
