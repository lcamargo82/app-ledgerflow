import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/transaction.dart';
import 'transactions_api.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(api: TransactionsApi(ref.watch(dioProvider)));
});

class TransactionsRepository {
  const TransactionsRepository({required this.api});

  final TransactionsApi api;

  Future<TransactionPage> list({
    required String workspaceId,
    int page = 1,
    int perPage = 30,
    TransactionType? type,
  }) async {
    try {
      return api.list(
        workspaceId: workspaceId,
        page: page,
        perPage: perPage,
        type: type,
      );
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<MonthlySummary> monthlySummary({
    required String workspaceId,
    required int month,
    required int year,
  }) async {
    try {
      return api.monthlySummary(
        workspaceId: workspaceId,
        month: month,
        year: year,
      );
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<LedgerTransaction> create({
    required String workspaceId,
    required CreateTransactionRequest request,
  }) async {
    try {
      return api.create(workspaceId: workspaceId, request: request);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }
}
