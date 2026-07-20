import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ActiveWorkspaceStorage {
  Future<String?> read();
  Future<void> save(String workspaceId);
  Future<void> clear();
}

final activeWorkspaceStorageProvider = Provider<ActiveWorkspaceStorage>((ref) {
  return const SecureActiveWorkspaceStorage();
});

class SecureActiveWorkspaceStorage implements ActiveWorkspaceStorage {
  const SecureActiveWorkspaceStorage({
    this.storage = const FlutterSecureStorage(),
  });

  static const _workspaceIdKey = 'ledgerflow.active_workspace_id';

  final FlutterSecureStorage storage;

  @override
  Future<String?> read() => storage.read(key: _workspaceIdKey);

  @override
  Future<void> save(String workspaceId) {
    return storage.write(key: _workspaceIdKey, value: workspaceId);
  }

  @override
  Future<void> clear() => storage.delete(key: _workspaceIdKey);
}
