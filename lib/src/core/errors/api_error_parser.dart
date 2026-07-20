import 'package:dio/dio.dart';

import 'app_exception.dart';

class ApiErrorParser {
  const ApiErrorParser._();

  static AppException parse(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      final response = error.response;
      final data = response?.data;
      final message = _messageFromData(data) ?? _messageForType(error.type);

      return AppException(message, statusCode: response?.statusCode);
    }

    return const AppException('Ocorreu um erro inesperado. Tente novamente.');
  }

  static String? _messageFromData(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      if (message is List && message.isNotEmpty) {
        return message.whereType<String>().join('\n');
      }
    }

    return null;
  }

  static String _messageForType(DioExceptionType type) {
    return switch (type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'A conexao demorou demais. Tente novamente.',
      DioExceptionType.badCertificate || DioExceptionType.connectionError =>
        'Nao foi possivel conectar ao LedgerFlow.',
      _ => 'Ocorreu um erro inesperado. Tente novamente.',
    };
  }
}
