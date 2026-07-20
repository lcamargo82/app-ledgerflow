import 'package:dio/dio.dart';

import '../domain/workspace.dart';

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
}
