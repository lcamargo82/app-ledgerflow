import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/workspace_summary.dart';
import '../../data/workspaces_repository.dart';
import '../../domain/workspace.dart';

final workspaceControllerProvider = Provider<WorkspaceController>((ref) {
  final controller = WorkspaceController(
    ref.watch(workspacesRepositoryProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});

class WorkspaceController extends ChangeNotifier {
  WorkspaceController(this.repository);

  final WorkspacesRepository repository;

  String? _activeWorkspaceId;
  List<Workspace> _workspaces = const [];
  bool _isLoading = false;

  String? get activeWorkspaceId => _activeWorkspaceId;
  List<Workspace> get workspaces => _workspaces;
  bool get isLoading => _isLoading;

  Future<void> bootFromAuthWorkspaces({
    required WorkspaceSummary? currentWorkspace,
    required List<WorkspaceSummary> workspaces,
  }) async {
    final savedWorkspaceId = await repository.readActiveWorkspaceId();
    final exists = workspaces.any(
      (workspace) => workspace.id == savedWorkspaceId,
    );
    final fallback = currentWorkspace?.id ?? workspaces.firstOrNull?.id;
    final nextWorkspaceId = exists ? savedWorkspaceId : fallback;

    if (nextWorkspaceId != null) {
      await setActiveWorkspace(nextWorkspaceId);
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    _workspaces = await repository.list();

    if (_activeWorkspaceId == null ||
        !_workspaces.any((workspace) => workspace.id == _activeWorkspaceId)) {
      final fallback = _workspaces.firstOrNull?.id;
      if (fallback != null) {
        await setActiveWorkspace(fallback);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setActiveWorkspace(String workspaceId) async {
    _activeWorkspaceId = workspaceId;
    await repository.saveActiveWorkspaceId(workspaceId);
    notifyListeners();
  }

  Future<void> clear() async {
    _activeWorkspaceId = null;
    _workspaces = const [];
    await repository.clearActiveWorkspaceId();
    notifyListeners();
  }
}
