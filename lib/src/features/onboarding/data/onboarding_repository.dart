import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/active_workspace_storage.dart';
import '../domain/onboarding_choice.dart';
import '../domain/onboarding_result.dart';
import 'onboarding_api.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(
    api: OnboardingApi(ref.watch(dioProvider)),
    activeWorkspaceStorage: ref.watch(activeWorkspaceStorageProvider),
  );
});

class OnboardingRepository {
  const OnboardingRepository({
    required this.api,
    required this.activeWorkspaceStorage,
  });

  final OnboardingApi api;
  final ActiveWorkspaceStorage activeWorkspaceStorage;

  Future<OnboardingResult> onboard(OnboardingChoice choice) async {
    try {
      final result = await api.onboard(choice);
      final workspaceId = result.currentWorkspace?.id;

      if (workspaceId != null && workspaceId.isNotEmpty) {
        await activeWorkspaceStorage.save(workspaceId);
      }

      return result;
    } catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }
}
