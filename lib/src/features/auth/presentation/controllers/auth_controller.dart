import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_me.dart';
import '../../domain/user_profile.dart';
import '../../../onboarding/domain/onboarding_result.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  final controller = AuthController(ref.watch(authRepositoryProvider));
  ref.onDispose(controller.dispose);
  return controller;
});

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  AuthMe? _me;
  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  AuthMe? get me => _me;
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get onboardingRequired => _me?.onboardingRequired ?? false;

  Future<void> boot() async {
    if (_status != AuthStatus.unknown) {
      return;
    }

    await _run(() async {
      final me = await _repository.boot();

      if (me == null) {
        _status = AuthStatus.unauthenticated;
        return;
      }

      _me = me;
      _status = AuthStatus.authenticated;
    });
  }

  Future<bool> login({required String email, required String password}) async {
    return _run(() async {
      final session = await _repository.login(
        email: email.trim().toLowerCase(),
        password: password,
      );
      _me = session.me;
      _profile = session.user;
      _status = AuthStatus.authenticated;
    });
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    return _run(() async {
      final session = await _repository.signup(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
      );
      _me = session.me;
      _profile = session.user;
      _status = AuthStatus.authenticated;
    });
  }

  Future<bool> forgotPassword(String email) async {
    return _run(() async {
      await _repository.forgotPassword(email.trim().toLowerCase());
    });
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _repository.logout();

    _me = null;
    _profile = null;
    _status = AuthStatus.unauthenticated;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void applyOnboardingResult(OnboardingResult result) {
    final current = _me;

    if (current == null) {
      return;
    }

    _me = AuthMe(
      userId: current.userId,
      email: current.email,
      tokenVersion: current.tokenVersion,
      onboardingRequired: result.onboardingRequired,
      currentWorkspace: result.currentWorkspace,
      workspaces: result.workspaces,
    );
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> loadProfile() async {
    return _run(() async {
      _profile = await _repository.profile();
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Ocorreu um erro inesperado. Tente novamente.';
      _isLoading = false;
      if (_status == AuthStatus.unknown) {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
      return false;
    }
  }
}
