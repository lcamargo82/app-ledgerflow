import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/active_workspace_storage.dart';
import '../../data/dashboard_repository.dart';
import '../../domain/dashboard_summary.dart';

final dashboardControllerProvider = ChangeNotifierProvider<DashboardController>(
  (ref) {
    final controller = DashboardController(
      repository: ref.watch(dashboardRepositoryProvider),
      activeWorkspaceStorage: ref.watch(activeWorkspaceStorageProvider),
    );
    return controller;
  },
);

class DashboardController extends ChangeNotifier {
  DashboardController({
    required this.repository,
    required this.activeWorkspaceStorage,
  });

  final DashboardRepository repository;
  final ActiveWorkspaceStorage activeWorkspaceStorage;

  DashboardSummary? _summary;
  bool _isLoading = false;
  String? _errorMessage;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;

  DashboardSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get month => _month;
  int get year => _year;

  Future<void> load({DateTime? period}) async {
    final workspaceId = await activeWorkspaceStorage.read();

    if (workspaceId == null || workspaceId.isEmpty) {
      _summary = null;
      _errorMessage = 'Workspace ativo nao encontrado.';
      notifyListeners();
      return;
    }

    final selectedPeriod = period ?? DateTime.now();
    _month = selectedPeriod.month;
    _year = selectedPeriod.year;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await repository.summary(
        workspaceId: workspaceId,
        month: _month,
        year: _year,
      );
    } catch (error) {
      _summary = null;
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel carregar o dashboard.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
