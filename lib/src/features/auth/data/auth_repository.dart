import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_me.dart';
import '../domain/auth_session.dart';
import '../domain/user_profile.dart';
import 'auth_api.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: AuthApi(ref.watch(dioProvider)),
    storage: ref.watch(tokenStorageProvider),
  );
});

class AuthRepository {
  const AuthRepository({required this.api, required this.storage});

  final AuthApi api;
  final TokenStorage storage;

  Future<AuthMe?> boot() async {
    try {
      final tokens = await storage.read();

      if (tokens == null) {
        return null;
      }

      return api.me();
    } catch (error) {
      await storage.clear();
      throw ApiErrorParser.parse(error);
    }
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await api.login(email: email, password: password);
      await storage.save(response.tokens);
      final me = await api.me();

      return AuthSession(tokens: response.tokens, user: response.user, me: me);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<AuthSession> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await api.signup(
        name: name,
        email: email,
        password: password,
      );
      await storage.save(response.tokens);
      final me = await api.me();

      return AuthSession(tokens: response.tokens, user: response.user, me: me);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await api.forgotPassword(email);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<UserProfile> profile() async {
    try {
      return api.profile();
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<void> logout() async {
    try {
      await api.logout();
    } catch (_) {
      // Local logout must always win, even when the session is already invalid.
    } finally {
      await storage.clear();
    }
  }
}
