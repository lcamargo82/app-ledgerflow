import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/active_workspace_storage.dart';
import '../../data/accounts_repository.dart';
import '../../domain/account.dart';
import '../../domain/institution.dart';

final accountsControllerProvider = ChangeNotifierProvider<AccountsController>((
  ref,
) {
  final controller = AccountsController(
    repository: ref.watch(accountsRepositoryProvider),
    activeWorkspaceStorage: ref.watch(activeWorkspaceStorageProvider),
  );
  return controller;
});

class AccountsController extends ChangeNotifier {
  AccountsController({
    required this.repository,
    required this.activeWorkspaceStorage,
  });

  final AccountsRepository repository;
  final ActiveWorkspaceStorage activeWorkspaceStorage;

  List<Account> _accounts = const [];
  List<Institution> _institutions = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Account> get accounts => _accounts;
  List<Institution> get institutions => _institutions;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  int get totalIncludedCents => _accounts
      .where((account) => account.includeInTotal)
      .fold(0, (total, account) => total + account.balanceCents);

  Future<void> load() async {
    final workspaceId = await activeWorkspaceStorage.read();

    if (workspaceId == null || workspaceId.isEmpty) {
      _accounts = const [];
      _errorMessage = 'Workspace ativo nao encontrado.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.listAccounts(workspaceId),
        repository.listInstitutions(),
      ]);
      _accounts = results[0] as List<Account>;
      _institutions = results[1] as List<Institution>;
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel carregar suas contas.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> create(CreateAccountRequest request) async {
    final workspaceId = await activeWorkspaceStorage.read();

    if (workspaceId == null || workspaceId.isEmpty) {
      _errorMessage = 'Workspace ativo nao encontrado.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final account = await repository.createAccount(
        workspaceId: workspaceId,
        request: request,
      );
      _accounts = [..._accounts, account];
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel criar a conta.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
