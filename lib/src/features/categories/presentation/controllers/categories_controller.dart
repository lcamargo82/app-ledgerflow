import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/active_workspace_storage.dart';
import '../../data/categories_repository.dart';
import '../../domain/category.dart';

final categoriesControllerProvider = Provider<CategoriesController>((ref) {
  final controller = CategoriesController(
    repository: ref.watch(categoriesRepositoryProvider),
    activeWorkspaceStorage: ref.watch(activeWorkspaceStorageProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});

class CategoriesController extends ChangeNotifier {
  CategoriesController({
    required this.repository,
    required this.activeWorkspaceStorage,
  });

  final CategoriesRepository repository;
  final ActiveWorkspaceStorage activeWorkspaceStorage;

  List<Category> _categories = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String _search = '';

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get search => _search;

  List<Category> byType(CategoryType type) {
    return _categories.where((category) => category.type == type).toList();
  }

  Future<void> load({String? search}) async {
    final workspaceId = await activeWorkspaceStorage.read();

    if (workspaceId == null || workspaceId.isEmpty) {
      _errorMessage = 'Workspace ativo nao encontrado.';
      _categories = const [];
      notifyListeners();
      return;
    }

    _search = search ?? _search;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.list(
          workspaceId: workspaceId,
          type: CategoryType.income,
          search: _search,
        ),
        repository.list(
          workspaceId: workspaceId,
          type: CategoryType.expense,
          search: _search,
        ),
      ]);
      _categories = [...results[0], ...results[1]];
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel carregar categorias.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> create(CreateCategoryRequest request) async {
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
      final category = await repository.create(
        workspaceId: workspaceId,
        request: request,
      );
      _categories = [..._categories, category];
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel criar a categoria.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
