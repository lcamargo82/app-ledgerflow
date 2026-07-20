import 'package:dio/dio.dart';

import '../domain/account.dart';

class AccountsApi {
  const AccountsApi(this._dio);

  final Dio _dio;

  Future<List<Account>> list(String workspaceId) async {
    final response = await _dio.get<List<dynamic>>(
      '/workspaces/$workspaceId/accounts',
    );

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Account.fromJson)
        .toList();
  }

  Future<Account> create({
    required String workspaceId,
    required CreateAccountRequest request,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workspaces/$workspaceId/accounts',
      data: request.toJson(),
    );

    return Account.fromJson(response.data ?? {});
  }
}
