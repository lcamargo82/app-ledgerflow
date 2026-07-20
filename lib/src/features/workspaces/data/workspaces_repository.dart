import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/active_workspace_storage.dart';
import '../domain/workspace.dart';
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

  Future<String?> readActiveWorkspaceId() => storage.read();

  Future<void> saveActiveWorkspaceId(String workspaceId) {
    return storage.save(workspaceId);
  }

  Future<void> clearActiveWorkspaceId() => storage.clear();
}
