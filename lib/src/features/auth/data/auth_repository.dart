import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/active_workspace_storage.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_me.dart';
import '../domain/auth_session.dart';
import '../domain/user_profile.dart';
import 'auth_api.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: AuthApi(ref.watch(dioProvider)),
    storage: ref.watch(tokenStorageProvider),
    activeWorkspaceStorage: ref.watch(activeWorkspaceStorageProvider),
  );
});

class AuthRepository {
  const AuthRepository({
    required this.api,
    required this.storage,
    required this.activeWorkspaceStorage,
  });

  final AuthApi api;
  final TokenStorage storage;
  final ActiveWorkspaceStorage activeWorkspaceStorage;

  Future<AuthMe?> boot() async {
    try {
      final tokens = await storage.read();

      if (tokens == null) {
        return null;
      }

      final me = await api.me();
      await _saveActiveWorkspace(me);

      return me;
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
      await _saveActiveWorkspace(me);

      return AuthSession(tokens: response.tokens, user: response.user, me: me);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<AuthSession> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await api.signup(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      await storage.save(response.tokens);
      final me = await api.me();
      await _saveActiveWorkspace(me);

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

  Future<AuthMe> me() async {
    try {
      final me = await api.me();
      await _saveActiveWorkspace(me);

      return me;
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

  Future<UserProfile> updateProfile({
    String? name,
    String? email,
    String? oldPassword,
    String? password,
  }) async {
    try {
      return api.updateProfile(
        name: name,
        email: email,
        oldPassword: oldPassword,
        password: password,
      );
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
      await activeWorkspaceStorage.clear();
    }
  }

  Future<void> _saveActiveWorkspace(AuthMe me) async {
    final workspaceId =
        me.currentWorkspace?.id ?? me.workspaces.firstOrNull?.id;

    if (workspaceId != null && workspaceId.isNotEmpty) {
      await activeWorkspaceStorage.save(workspaceId);
    }
  }
}
