import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/account.dart';
import '../domain/institution.dart';
import 'accounts_api.dart';
import 'institutions_api.dart';

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return AccountsRepository(
    accountsApi: AccountsApi(dio),
    institutionsApi: InstitutionsApi(dio),
  );
});

class AccountsRepository {
  const AccountsRepository({
    required this.accountsApi,
    required this.institutionsApi,
  });

  final AccountsApi accountsApi;
  final InstitutionsApi institutionsApi;

  Future<List<Account>> listAccounts(String workspaceId) async {
    try {
      return accountsApi.list(workspaceId);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<Account> createAccount({
    required String workspaceId,
    required CreateAccountRequest request,
  }) async {
    try {
      return accountsApi.create(workspaceId: workspaceId, request: request);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<List<Institution>> listInstitutions({String? search}) async {
    try {
      return institutionsApi.list(search: search);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }
}
