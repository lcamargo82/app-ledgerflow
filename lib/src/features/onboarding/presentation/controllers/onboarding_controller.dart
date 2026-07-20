import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/onboarding_repository.dart';
import '../../domain/onboarding_choice.dart';

final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  final controller = OnboardingController(
    repository: ref.watch(onboardingRepositoryProvider),
    authController: ref.watch(authControllerProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});

class OnboardingController extends ChangeNotifier {
  OnboardingController({
    required this.repository,
    required this.authController,
  });

  final OnboardingRepository repository;
  final AuthController authController;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> submit(OnboardingChoice choice) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.onboard(choice);
      authController.applyOnboardingResult(result);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error is AppException
          ? error.message
          : 'Nao foi possivel concluir o onboarding.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
