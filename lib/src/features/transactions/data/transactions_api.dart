import 'package:dio/dio.dart';

import '../domain/transaction.dart';

class TransactionsApi {
  const TransactionsApi(this._dio);

  final Dio _dio;

  Future<TransactionPage> list({
    required String workspaceId,
    int page = 1,
    int perPage = 30,
    TransactionType? type,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/workspaces/$workspaceId/transactions',
      queryParameters: {
        'page': page,
        'perPage': perPage,
        if (type != null) 'type': type.apiValue,
      },
    );

    return TransactionPage.fromJson(_unwrapObject(response.data));
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

    return MonthlySummary.fromJson(_unwrapObject(response.data));
  }

  Future<LedgerTransaction> create({
    required String workspaceId,
    required CreateTransactionRequest request,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workspaces/$workspaceId/transactions',
      data: request.toJson(),
    );

    return LedgerTransaction.fromJson(_unwrapObject(response.data));
  }

  Map<String, dynamic> _unwrapObject(Map<String, dynamic>? json) {
    final data = json?['data'];

    return data is Map<String, dynamic> ? data : json ?? {};
  }
}
