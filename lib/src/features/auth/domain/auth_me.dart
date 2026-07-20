import 'workspace_summary.dart';

class AuthMe {
  const AuthMe({
    required this.userId,
    required this.email,
    required this.tokenVersion,
    required this.onboardingRequired,
    required this.workspaces,
    this.currentWorkspace,
  });

  final String userId;
  final String email;
  final int tokenVersion;
  final bool onboardingRequired;
  final WorkspaceSummary? currentWorkspace;
  final List<WorkspaceSummary> workspaces;

  factory AuthMe.fromJson(Map<String, dynamic> json) {
    final currentWorkspaceJson = json['currentWorkspace'];
    final workspacesJson = json['workspaces'];

    return AuthMe(
      userId: json['sub'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      tokenVersion: json['tokenVersion'] as int? ?? 0,
      onboardingRequired: json['onboardingRequired'] as bool? ?? false,
      currentWorkspace: currentWorkspaceJson is Map<String, dynamic>
          ? WorkspaceSummary.fromJson(currentWorkspaceJson)
          : null,
      workspaces: workspacesJson is List
          ? workspacesJson
                .whereType<Map<String, dynamic>>()
                .map(WorkspaceSummary.fromJson)
                .toList()
          : const [],
    );
  }
}
