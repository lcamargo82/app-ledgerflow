import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/active_workspace_storage.dart';
import '../../../dashboard/data/dashboard_repository.dart';
import '../../../dashboard/domain/dashboard_summary.dart';
import '../../../transactions/data/transactions_repository.dart';
import '../../../transactions/domain/transaction.dart';
import '../../domain/report_period.dart';

final reportsControllerProvider = ChangeNotifierProvider<ReportsController>((
  ref,
) {
  final controller = ReportsController(
    transactionsRepository: ref.watch(transactionsRepositoryProvider),
    dashboardRepository: ref.watch(dashboardRepositoryProvider),
    activeWorkspaceStorage: ref.watch(activeWorkspaceStorageProvider),
  );
  return controller;
});

class ReportsController extends ChangeNotifier {
  ReportsController({
    required this.transactionsRepository,
    required this.dashboardRepository,
    required this.activeWorkspaceStorage,
  });

  final TransactionsRepository transactionsRepository;
  final DashboardRepository dashboardRepository;
  final ActiveWorkspaceStorage activeWorkspaceStorage;

  ReportPeriod _period = ReportPeriod.current();
  MonthlySummary? _monthlySummary;
  DashboardSummary? _dashboardSummary;
  bool _isLoading = false;
  String? _errorMessage;

  ReportPeriod get period => _period;
  MonthlySummary? get monthlySummary => _monthlySummary;
  DashboardSummary? get dashboardSummary => _dashboardSummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load({ReportPeriod? period}) async {
    final workspaceId = await activeWorkspaceStorage.read();

    if (workspaceId == null || workspaceId.isEmpty) {
      _monthlySummary = null;
      _dashboardSummary = null;
      _errorMessage = 'Workspace ativo nao encontrado.';
      notifyListeners();
      return;
    }

    _period = period ?? _period;
    _monthlySummary = null;
    _dashboardSummary = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        transactionsRepository.monthlySummary(
          workspaceId: workspaceId,
          month: _period.month,
          year: _period.year,
        ),
        dashboardRepository.summary(
          workspaceId: workspaceId,
          month: _period.month,
          year: _period.year,
        ),
      ]);
      _monthlySummary = results[0] as MonthlySummary;
      _dashboardSummary = results[1] as DashboardSummary;
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel carregar relatorios.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> previousPeriod() => load(period: _period.previous());

  Future<void> nextPeriod() => load(period: _period.next());
}
