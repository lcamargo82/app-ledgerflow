import 'package:dio/dio.dart';

import '../domain/auth_me.dart';
import '../domain/auth_tokens.dart';
import '../domain/user_profile.dart';
import 'models/auth_response_dto.dart';

class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    return AuthResponseDto.fromJson(response.data ?? {});
  }

  Future<AuthResponseDto> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/signup',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'passwordConfirmation': passwordConfirmation,
      },
    );

    return AuthResponseDto.fromJson(response.data ?? {});
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    return AuthTokens.fromJson(response.data ?? {});
  }

  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post<void>('/auth/forgot-password', data: {'email': email});
  }

  Future<AuthMe> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');

    return AuthMe.fromJson(response.data ?? {});
  }

  Future<UserProfile> profile() async {
    final response = await _dio.get<Map<String, dynamic>>('/users/profile');

    return UserProfile.fromJson(response.data ?? {});
  }

  Future<UserProfile> updateProfile({
    String? name,
    String? email,
    String? oldPassword,
    String? password,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/profile',
      data: {
        'name': ?name,
        'email': ?email,
        'oldPassword': ?oldPassword,
        'password': ?password,
      },
    );

    return UserProfile.fromJson(response.data ?? {});
  }
}
