enum WorkspaceRole {
  owner('OWNER', 'Proprietario'),
  admin('ADMIN', 'Administrador'),
  editor('EDITOR', 'Editor'),
  viewer('VIEWER', 'Visualizador');

  const WorkspaceRole(this.apiValue, this.label);

  final String apiValue;
  final String label;

  bool get canWrite => this != WorkspaceRole.viewer;
  bool get canManageMembers =>
      this == WorkspaceRole.owner || this == WorkspaceRole.admin;

  static WorkspaceRole fromApi(String value) {
    return WorkspaceRole.values.firstWhere(
      (role) => role.apiValue == value,
      orElse: () => WorkspaceRole.viewer,
    );
  }
}

enum WorkspaceInvitationStatus {
  pending('PENDING', 'Pendente'),
  accepted('ACCEPTED', 'Aceito'),
  declined('DECLINED', 'Recusado'),
  canceled('CANCELED', 'Cancelado'),
  expired('EXPIRED', 'Expirado');

  const WorkspaceInvitationStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static WorkspaceInvitationStatus fromApi(String value) {
    return WorkspaceInvitationStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => WorkspaceInvitationStatus.pending,
    );
  }
}

class WorkspaceMemberUser {
  const WorkspaceMemberUser({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  factory WorkspaceMemberUser.fromJson(Map<String, dynamic> json) {
    return WorkspaceMemberUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class WorkspaceMember {
  const WorkspaceMember({
    required this.id,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.workspaceId,
    this.user,
  });

  final String id;
  final String? workspaceId;
  final String userId;
  final WorkspaceRole role;
  final DateTime joinedAt;
  final WorkspaceMemberUser? user;

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];

    return WorkspaceMember(
      id: json['id'] as String? ?? '',
      workspaceId: json['workspaceId'] as String?,
      userId: json['userId'] as String? ?? '',
      role: WorkspaceRole.fromApi(json['role'] as String? ?? 'VIEWER'),
      joinedAt:
          DateTime.tryParse(json['joinedAt'] as String? ?? '') ??
          DateTime.now(),
      user: userJson is Map<String, dynamic>
          ? WorkspaceMemberUser.fromJson(userJson)
          : null,
    );
  }
}

class WorkspaceInvitation {
  const WorkspaceInvitation({
    required this.id,
    required this.workspaceId,
    required this.email,
    required this.role,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.invitedByUserId,
    this.acceptedByUserId,
    this.acceptedAt,
    this.updatedAt,
    this.acceptToken,
  });

  final String id;
  final String workspaceId;
  final String email;
  final WorkspaceRole role;
  final WorkspaceInvitationStatus status;
  final DateTime expiresAt;
  final DateTime createdAt;
  final String? invitedByUserId;
  final String? acceptedByUserId;
  final DateTime? acceptedAt;
  final DateTime? updatedAt;
  final String? acceptToken;

  factory WorkspaceInvitation.fromJson(Map<String, dynamic> json) {
    return WorkspaceInvitation(
      id: json['id'] as String? ?? '',
      workspaceId: json['workspaceId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: WorkspaceRole.fromApi(json['role'] as String? ?? 'VIEWER'),
      status: WorkspaceInvitationStatus.fromApi(
        json['status'] as String? ?? 'PENDING',
      ),
      invitedByUserId: json['invitedByUserId'] as String?,
      acceptedByUserId: json['acceptedByUserId'] as String?,
      expiresAt:
          DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now(),
      acceptedAt: DateTime.tryParse(json['acceptedAt'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      acceptToken: json['acceptToken'] as String?,
    );
  }
}

class CreateWorkspaceInvitationRequest {
  const CreateWorkspaceInvitationRequest({
    required this.email,
    required this.role,
  });

  final String email;
  final WorkspaceRole role;

  Map<String, dynamic> toJson() {
    return {'email': email.trim().toLowerCase(), 'role': role.apiValue};
  }
}

class UpdateWorkspaceMemberRequest {
  const UpdateWorkspaceMemberRequest({required this.role});

  final WorkspaceRole role;

  Map<String, dynamic> toJson() {
    return {'role': role.apiValue};
  }
}

class RespondWorkspaceInvitationRequest {
  const RespondWorkspaceInvitationRequest({required this.token});

  final String token;

  Map<String, dynamic> toJson() {
    return {'token': token.trim()};
  }
}
