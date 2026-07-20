import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/active_workspace_storage.dart';
import '../../../accounts/data/accounts_repository.dart';
import '../../../accounts/domain/account.dart';
import '../../../categories/data/categories_repository.dart';
import '../../../categories/domain/category.dart';
import '../../data/transactions_repository.dart';
import '../../domain/transaction.dart';

final transactionsControllerProvider =
    ChangeNotifierProvider<TransactionsController>((ref) {
      final controller = TransactionsController(
        repository: ref.watch(transactionsRepositoryProvider),
        accountsRepository: ref.watch(accountsRepositoryProvider),
        categoriesRepository: ref.watch(categoriesRepositoryProvider),
        activeWorkspaceStorage: ref.watch(activeWorkspaceStorageProvider),
      );
      return controller;
    });

class TransactionsController extends ChangeNotifier {
  TransactionsController({
    required this.repository,
    required this.accountsRepository,
    required this.categoriesRepository,
    required this.activeWorkspaceStorage,
  });

  final TransactionsRepository repository;
  final AccountsRepository accountsRepository;
  final CategoriesRepository categoriesRepository;
  final ActiveWorkspaceStorage activeWorkspaceStorage;

  List<LedgerTransaction> _transactions = const [];
  List<Account> _accounts = const [];
  List<Category> _categories = const [];
  MonthlySummary? _summary;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<LedgerTransaction> get transactions => _transactions;
  List<Account> get accounts => _accounts;
  List<Category> get categories => _categories;
  MonthlySummary? get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<Category> categoriesFor(TransactionType type) {
    final categoryType = type == TransactionType.income
        ? CategoryType.income
        : CategoryType.expense;

    return _categories
        .where((category) => category.type == categoryType)
        .toList();
  }

  Account? accountById(String id) {
    return _accounts.where((account) => account.id == id).firstOrNull;
  }

  Category? categoryById(String id) {
    return _categories.where((category) => category.id == id).firstOrNull;
  }

  Future<void> load() async {
    final workspaceId = await activeWorkspaceStorage.read();

    if (workspaceId == null || workspaceId.isEmpty) {
      _errorMessage = 'Workspace ativo nao encontrado.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final results = await Future.wait([
        repository.list(workspaceId: workspaceId),
        repository.monthlySummary(
          workspaceId: workspaceId,
          month: now.month,
          year: now.year,
        ),
        accountsRepository.listAccounts(workspaceId),
        categoriesRepository.list(workspaceId: workspaceId),
      ]);
      _transactions = (results[0] as TransactionPage).data;
      _summary = results[1] as MonthlySummary;
      _accounts = results[2] as List<Account>;
      _categories = results[3] as List<Category>;
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel carregar transacoes.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> create(CreateTransactionRequest request) async {
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
      await repository.create(workspaceId: workspaceId, request: request);
      _isSaving = false;
      notifyListeners();
      await load();
      return true;
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel criar a transacao.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
