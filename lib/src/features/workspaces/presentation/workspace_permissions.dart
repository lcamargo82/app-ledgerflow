import '../../auth/presentation/controllers/auth_controller.dart';
import 'controllers/workspace_collaboration_controller.dart';

bool canWriteWorkspace({
  required AuthController auth,
  required WorkspaceCollaborationController collaboration,
}) {
  final userId = auth.me?.userId;

  if (userId == null || userId.isEmpty) {
    return true;
  }

  final role = collaboration.roleForUser(userId);

  return role?.canWrite ?? true;
}
