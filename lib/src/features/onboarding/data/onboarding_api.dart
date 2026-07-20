import 'package:dio/dio.dart';

import '../domain/onboarding_choice.dart';
import '../domain/onboarding_result.dart';

class OnboardingApi {
  const OnboardingApi(this._dio);

  final Dio _dio;

  Future<OnboardingResult> onboard(OnboardingChoice choice) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workspaces/onboarding',
      data: {'choice': choice.apiValue},
    );

    return OnboardingResult.fromJson(response.data ?? {});
  }
}
