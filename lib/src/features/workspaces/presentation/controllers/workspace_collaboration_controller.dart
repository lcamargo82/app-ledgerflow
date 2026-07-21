import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/active_workspace_storage.dart';
import '../../data/workspaces_repository.dart';
import '../../domain/workspace_collaboration.dart';

final workspaceCollaborationControllerProvider =
    ChangeNotifierProvider<WorkspaceCollaborationController>((ref) {
      return WorkspaceCollaborationController(
        repository: ref.watch(workspacesRepositoryProvider),
        activeWorkspaceStorage: ref.watch(activeWorkspaceStorageProvider),
      );
    });

class WorkspaceCollaborationController extends ChangeNotifier {
  WorkspaceCollaborationController({
    required this.repository,
    required this.activeWorkspaceStorage,
  });

  final WorkspacesRepository repository;
  final ActiveWorkspaceStorage activeWorkspaceStorage;

  List<WorkspaceMember> _members = const [];
  List<WorkspaceInvitation> _invitations = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<WorkspaceMember> get members => _members;
  List<WorkspaceInvitation> get invitations => _invitations;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  WorkspaceRole? roleForUser(String userId) {
    return _members
        .where((member) => member.userId == userId)
        .firstOrNull
        ?.role;
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
      final results = await Future.wait([
        repository.listMembers(workspaceId),
        repository.listInvitations(workspaceId),
      ]);
      _members = results[0] as List<WorkspaceMember>;
      _invitations = results[1] as List<WorkspaceInvitation>;
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel carregar membros.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createInvitation(
    CreateWorkspaceInvitationRequest request,
  ) async {
    return _runMutation((workspaceId) async {
      await repository.createInvitation(
        workspaceId: workspaceId,
        request: request,
      );
    });
  }

  Future<bool> cancelInvitation(String invitationId) async {
    return _runMutation((workspaceId) async {
      await repository.cancelInvitation(
        workspaceId: workspaceId,
        invitationId: invitationId,
      );
    });
  }

  Future<bool> updateMember({
    required String memberId,
    required WorkspaceRole role,
  }) async {
    return _runMutation((workspaceId) async {
      await repository.updateMember(
        workspaceId: workspaceId,
        memberId: memberId,
        request: UpdateWorkspaceMemberRequest(role: role),
      );
    });
  }

  Future<bool> removeMember(String memberId) async {
    return _runMutation((workspaceId) async {
      await repository.removeMember(
        workspaceId: workspaceId,
        memberId: memberId,
      );
    });
  }

  Future<bool> acceptInvitation(String token) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final member = await repository.acceptInvitation(token);

      if (member.workspaceId != null && member.workspaceId!.isNotEmpty) {
        await activeWorkspaceStorage.save(member.workspaceId!);
      }

      _isSaving = false;
      notifyListeners();
      await load();
      return true;
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel aceitar o convite.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> declineInvitation(String token) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.declineInvitation(token);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel recusar o convite.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _runMutation(
    Future<void> Function(String workspaceId) action,
  ) async {
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
      await action(workspaceId);
      _isSaving = false;
      notifyListeners();
      await load();
      return true;
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel atualizar o compartilhamento.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
