import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/dashboard_summary.dart';
import 'dashboard_api.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(api: DashboardApi(ref.watch(dioProvider)));
});

class DashboardRepository {
  const DashboardRepository({required this.api});

  final DashboardApi api;

  Future<DashboardSummary> summary({
    required String workspaceId,
    required int month,
    required int year,
  }) async {
    try {
      return api.summary(workspaceId: workspaceId, month: month, year: year);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }
}
