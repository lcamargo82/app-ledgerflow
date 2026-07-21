import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerflow/src/features/workspaces/domain/workspace_collaboration.dart';

void main() {
  group('WorkspaceRole', () {
    test('maps permissions from role', () {
      expect(WorkspaceRole.owner.canManageMembers, isTrue);
      expect(WorkspaceRole.admin.canManageMembers, isTrue);
      expect(WorkspaceRole.editor.canManageMembers, isFalse);
      expect(WorkspaceRole.viewer.canWrite, isFalse);
    });
  });

  group('WorkspaceMember', () {
    test('parses member with user summary', () {
      final member = WorkspaceMember.fromJson({
        'id': 'membership-1',
        'workspaceId': 'workspace-1',
        'userId': 'user-1',
        'role': 'EDITOR',
        'joinedAt': '2026-07-21T12:00:00.000Z',
        'user': {
          'id': 'user-1',
          'name': 'Leandro',
          'email': 'leandro@example.com',
        },
      });

      expect(member.id, 'membership-1');
      expect(member.workspaceId, 'workspace-1');
      expect(member.role, WorkspaceRole.editor);
      expect(member.user?.email, 'leandro@example.com');
    });
  });

  group('WorkspaceInvitation', () {
    test('parses invitation with accept token', () {
      final invitation = WorkspaceInvitation.fromJson({
        'id': 'invitation-1',
        'workspaceId': 'workspace-1',
        'email': 'pessoa@example.com',
        'role': 'VIEWER',
        'status': 'PENDING',
        'expiresAt': '2026-07-28T12:00:00.000Z',
        'createdAt': '2026-07-21T12:00:00.000Z',
        'acceptToken': 'token-exibido-apenas-na-criacao',
      });

      expect(invitation.email, 'pessoa@example.com');
      expect(invitation.role, WorkspaceRole.viewer);
      expect(invitation.status, WorkspaceInvitationStatus.pending);
      expect(invitation.acceptToken, isNotNull);
    });
  });

  group('requests', () {
    test('serializes invitation request', () {
      const request = CreateWorkspaceInvitationRequest(
        email: ' Pessoa@Example.COM ',
        role: WorkspaceRole.editor,
      );

      expect(request.toJson(), {
        'email': 'pessoa@example.com',
        'role': 'EDITOR',
      });
    });

    test('serializes invitation response token', () {
      const request = RespondWorkspaceInvitationRequest(token: ' token ');

      expect(request.toJson(), {'token': 'token'});
    });
  });
}
