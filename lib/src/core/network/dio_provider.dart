import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import '../../features/auth/domain/auth_tokens.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(_AuthInterceptor(dio: dio, storage: storage));

  if (kDebugMode) {
    dio.interceptors.add(const _SafeHttpLogInterceptor());
  }

  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({required this.dio, required this.storage});

  final Dio dio;
  final TokenStorage storage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokens = await storage.read();

    if (tokens != null && !_isAuthPublicRoute(options.path)) {
      options.headers['Authorization'] =
          '${tokens.tokenType} ${tokens.accessToken}';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final canRefresh =
        err.response?.statusCode == 401 &&
        request.extra['retriedAfterRefresh'] != true &&
        !_isRefreshRoute(request.path);

    if (!canRefresh) {
      handler.next(err);
      return;
    }

    final currentTokens = await storage.read();
    final refreshToken = currentTokens?.refreshToken;

    if (refreshToken == null) {
      handler.next(err);
      return;
    }

    try {
      final refreshDio = Dio(dio.options);
      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final tokens = AuthTokens.fromJson(response.data ?? {});

      await storage.save(tokens);

      final retryOptions = request.copyWith(
        headers: {
          ...request.headers,
          'Authorization': '${tokens.tokenType} ${tokens.accessToken}',
        },
        extra: {...request.extra, 'retriedAfterRefresh': true},
      );
      final retryResponse = await dio.fetch<dynamic>(retryOptions);

      handler.resolve(retryResponse);
    } catch (_) {
      await storage.clear();
      handler.next(err);
    }
  }

  bool _isAuthPublicRoute(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/signup') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password');
  }

  bool _isRefreshRoute(String path) => path.contains('/auth/refresh');
}

class _SafeHttpLogInterceptor extends Interceptor {
  const _SafeHttpLogInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[HTTP] --> ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '[HTTP] <-- ${response.statusCode} '
      '${response.requestOptions.method} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    final statusCode = err.response?.statusCode;
    final message = _safeMessage(err.response?.data) ?? err.message;

    debugPrint(
      '[HTTP] !! ${statusCode ?? '-'} ${request.method} ${request.uri} '
      '${message ?? ''}',
    );
    handler.next(err);
  }

  String? _safeMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String) {
        return message;
      }

      if (message is List) {
        return message.whereType<String>().join(' | ');
      }
    }

    return null;
  }
}
