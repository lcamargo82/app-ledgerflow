import 'package:dio/dio.dart';

import '../domain/institution.dart';

class InstitutionsApi {
  const InstitutionsApi(this._dio);

  final Dio _dio;

  Future<List<Institution>> list({String? search}) async {
    final response = await _dio.get<List<dynamic>>(
      '/institutions',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Institution.fromJson)
        .toList();
  }
}
