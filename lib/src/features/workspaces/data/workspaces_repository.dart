import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/active_workspace_storage.dart';
import '../domain/workspace.dart';
import '../domain/workspace_collaboration.dart';
import 'workspaces_api.dart';

final workspacesRepositoryProvider = Provider<WorkspacesRepository>((ref) {
  return WorkspacesRepository(
    api: WorkspacesApi(ref.watch(dioProvider)),
    storage: ref.watch(activeWorkspaceStorageProvider),
  );
});

class WorkspacesRepository {
  const WorkspacesRepository({required this.api, required this.storage});

  final WorkspacesApi api;
  final ActiveWorkspaceStorage storage;

  Future<List<Workspace>> list() async {
    try {
      return api.list();
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<List<WorkspaceMember>> listMembers(String workspaceId) async {
    try {
      return api.listMembers(workspaceId);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<List<WorkspaceInvitation>> listInvitations(String workspaceId) async {
    try {
      return api.listInvitations(workspaceId);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<WorkspaceInvitation> createInvitation({
    required String workspaceId,
    required CreateWorkspaceInvitationRequest request,
  }) async {
    try {
      return api.createInvitation(workspaceId: workspaceId, request: request);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<void> cancelInvitation({
    required String workspaceId,
    required String invitationId,
  }) async {
    try {
      await api.cancelInvitation(
        workspaceId: workspaceId,
        invitationId: invitationId,
      );
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<WorkspaceMember> updateMember({
    required String workspaceId,
    required String memberId,
    required UpdateWorkspaceMemberRequest request,
  }) async {
    try {
      return api.updateMember(
        workspaceId: workspaceId,
        memberId: memberId,
        request: request,
      );
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<void> removeMember({
    required String workspaceId,
    required String memberId,
  }) async {
    try {
      await api.removeMember(workspaceId: workspaceId, memberId: memberId);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<WorkspaceMember> acceptInvitation(String token) async {
    try {
      return api.acceptInvitation(
        RespondWorkspaceInvitationRequest(token: token),
      );
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<void> declineInvitation(String token) async {
    try {
      await api.declineInvitation(
        RespondWorkspaceInvitationRequest(token: token),
      );
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<String?> readActiveWorkspaceId() => storage.read();

  Future<void> saveActiveWorkspaceId(String workspaceId) {
    return storage.save(workspaceId);
  }

  Future<void> clearActiveWorkspaceId() => storage.clear();
}
