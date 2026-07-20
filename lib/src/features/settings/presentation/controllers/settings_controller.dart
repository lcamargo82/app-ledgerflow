import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/settings_preferences_storage.dart';
import '../../domain/settings_preferences.dart';

final settingsControllerProvider = Provider<SettingsController>((ref) {
  final controller = SettingsController(
    storage: ref.watch(settingsPreferencesStorageProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});

class SettingsController extends ChangeNotifier {
  SettingsController({required this.storage});

  final SettingsPreferencesStorage storage;

  SettingsPreferences _preferences = SettingsPreferences.defaults();
  bool _isLoading = false;

  SettingsPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _preferences = await storage.read();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setDarkThemeEnabled(bool value) async {
    _preferences = _preferences.copyWith(darkThemeEnabled: value);
    notifyListeners();
    await storage.save(_preferences);
  }

  Future<void> setBiometricsEnabled(bool value) async {
    _preferences = _preferences.copyWith(biometricsEnabled: value);
    notifyListeners();
    await storage.save(_preferences);
  }
}
