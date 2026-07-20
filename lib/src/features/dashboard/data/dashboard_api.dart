import 'package:dio/dio.dart';

import '../domain/dashboard_summary.dart';

class DashboardApi {
  const DashboardApi(this._dio);

  final Dio _dio;

  Future<DashboardSummary> summary({
    required String workspaceId,
    required int month,
    required int year,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/workspaces/$workspaceId/dashboard/summary',
      queryParameters: {'month': month, 'year': year},
    );

    return DashboardSummary.fromJson(response.data ?? {});
  }
}
