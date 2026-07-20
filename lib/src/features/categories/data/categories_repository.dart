import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/category.dart';
import 'categories_api.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(api: CategoriesApi(ref.watch(dioProvider)));
});

class CategoriesRepository {
  const CategoriesRepository({required this.api});

  final CategoriesApi api;

  Future<List<Category>> list({
    required String workspaceId,
    CategoryType? type,
    String? search,
  }) async {
    try {
      return api.list(workspaceId: workspaceId, type: type, search: search);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<Category> create({
    required String workspaceId,
    required CreateCategoryRequest request,
  }) async {
    try {
      return api.create(workspaceId: workspaceId, request: request);
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }
}
