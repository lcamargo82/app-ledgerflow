import 'package:dio/dio.dart';

import '../domain/category.dart';

class CategoriesApi {
  const CategoriesApi(this._dio);

  final Dio _dio;

  Future<List<Category>> list({
    required String workspaceId,
    CategoryType? type,
    String? search,
    bool includeSystem = false,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/workspaces/$workspaceId/categories',
      queryParameters: {
        if (type != null) 'type': type.apiValue,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'active': true,
        'includeSystem': includeSystem,
      },
    );

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .where((category) => category.type != CategoryType.adjustment)
        .toList();
  }

  Future<Category> create({
    required String workspaceId,
    required CreateCategoryRequest request,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workspaces/$workspaceId/categories',
      data: request.toJson(),
    );

    return Category.fromJson(response.data ?? {});
  }
}
