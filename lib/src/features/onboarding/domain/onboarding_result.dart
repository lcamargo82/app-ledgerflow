import '../../auth/domain/workspace_summary.dart';

class OnboardingResult {
  const OnboardingResult({
    required this.created,
    required this.onboardingRequired,
    required this.workspaces,
    this.currentWorkspace,
  });

  final bool created;
  final bool onboardingRequired;
  final WorkspaceSummary? currentWorkspace;
  final List<WorkspaceSummary> workspaces;

  factory OnboardingResult.fromJson(Map<String, dynamic> json) {
    final currentWorkspaceJson = json['currentWorkspace'];
    final workspacesJson = json['workspaces'];

    return OnboardingResult(
      created: json['created'] as bool? ?? false,
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
