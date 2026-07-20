import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/auth_tokens.dart';

abstract interface class TokenStorage {
  Future<AuthTokens?> read();
  Future<void> save(AuthTokens tokens);
  Future<void> clear();
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return const SecureTokenStorage();
});

class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage({this.storage = const FlutterSecureStorage()});

  static const _accessTokenKey = 'ledgerflow.access_token';
  static const _refreshTokenKey = 'ledgerflow.refresh_token';
  static const _tokenTypeKey = 'ledgerflow.token_type';
  static const _expiresInKey = 'ledgerflow.expires_in';
  static const _refreshExpiresInKey = 'ledgerflow.refresh_expires_in';

  final FlutterSecureStorage storage;

  @override
  Future<AuthTokens?> read() async {
    final accessToken = await storage.read(key: _accessTokenKey);
    final refreshToken = await storage.read(key: _refreshTokenKey);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: await storage.read(key: _tokenTypeKey) ?? 'Bearer',
      expiresIn: await storage.read(key: _expiresInKey) ?? '',
      refreshExpiresIn: await storage.read(key: _refreshExpiresInKey) ?? '',
    );
  }

  @override
  Future<void> save(AuthTokens tokens) async {
    await storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
    await storage.write(key: _tokenTypeKey, value: tokens.tokenType);
    await storage.write(key: _expiresInKey, value: tokens.expiresIn);
    await storage.write(
      key: _refreshExpiresInKey,
      value: tokens.refreshExpiresIn,
    );
  }

  @override
  Future<void> clear() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
    await storage.delete(key: _tokenTypeKey);
    await storage.delete(key: _expiresInKey);
    await storage.delete(key: _refreshExpiresInKey);
  }
}
