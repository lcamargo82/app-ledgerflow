import 'package:dio/dio.dart';

import '../domain/workspace.dart';
import '../domain/workspace_collaboration.dart';

class WorkspacesApi {
  const WorkspacesApi(this._dio);

  final Dio _dio;

  Future<List<Workspace>> list() async {
    final response = await _dio.get<List<dynamic>>('/workspaces');

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Workspace.fromJson)
        .toList();
  }

  Future<List<WorkspaceMember>> listMembers(String workspaceId) async {
    final response = await _dio.get<List<dynamic>>(
      '/workspaces/$workspaceId/members',
    );

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(WorkspaceMember.fromJson)
        .toList();
  }

  Future<List<WorkspaceInvitation>> listInvitations(String workspaceId) async {
    final response = await _dio.get<List<dynamic>>(
      '/workspaces/$workspaceId/invitations',
    );

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(WorkspaceInvitation.fromJson)
        .toList();
  }

  Future<WorkspaceInvitation> createInvitation({
    required String workspaceId,
    required CreateWorkspaceInvitationRequest request,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workspaces/$workspaceId/invitations',
      data: request.toJson(),
    );

    return WorkspaceInvitation.fromJson(response.data ?? {});
  }

  Future<void> cancelInvitation({
    required String workspaceId,
    required String invitationId,
  }) async {
    await _dio.delete<void>(
      '/workspaces/$workspaceId/invitations/$invitationId',
    );
  }

  Future<WorkspaceMember> updateMember({
    required String workspaceId,
    required String memberId,
    required UpdateWorkspaceMemberRequest request,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/workspaces/$workspaceId/members/$memberId',
      data: request.toJson(),
    );

    return WorkspaceMember.fromJson(response.data ?? {});
  }

  Future<void> removeMember({
    required String workspaceId,
    required String memberId,
  }) async {
    await _dio.delete<void>('/workspaces/$workspaceId/members/$memberId');
  }

  Future<WorkspaceMember> acceptInvitation(
    RespondWorkspaceInvitationRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workspace-invitations/accept',
      data: request.toJson(),
    );

    return WorkspaceMember.fromJson(response.data ?? {});
  }

  Future<void> declineInvitation(
    RespondWorkspaceInvitationRequest request,
  ) async {
    await _dio.post<void>(
      '/workspace-invitations/decline',
      data: request.toJson(),
    );
  }
}
