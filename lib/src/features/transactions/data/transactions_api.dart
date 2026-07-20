import 'package:dio/dio.dart';

import '../domain/transaction.dart';

class TransactionsApi {
  const TransactionsApi(this._dio);

  final Dio _dio;

  Future<TransactionPage> list({
    required String workspaceId,
    int page = 1,
    int perPage = 30,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/workspaces/$workspaceId/transactions',
      queryParameters: {'page': page, 'perPage': perPage},
    );

    return TransactionPage.fromJson(response.data ?? {});
  }

  Future<MonthlySummary> monthlySummary({
    required String workspaceId,
    required int month,
    required int year,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/workspaces/$workspaceId/transactions/monthly-summary',
      queryParameters: {'month': month, 'year': year},
    );

    return MonthlySummary.fromJson(response.data ?? {});
  }

  Future<LedgerTransaction> create({
    required String workspaceId,
    required CreateTransactionRequest request,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workspaces/$workspaceId/transactions',
      data: request.toJson(),
    );

    return LedgerTransaction.fromJson(response.data ?? {});
  }
}
