import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/settings_preferences.dart';

abstract interface class SettingsPreferencesStorage {
  Future<SettingsPreferences> read();
  Future<void> save(SettingsPreferences preferences);
}

final settingsPreferencesStorageProvider = Provider<SettingsPreferencesStorage>(
  (ref) {
    return const SecureSettingsPreferencesStorage();
  },
);

class SecureSettingsPreferencesStorage implements SettingsPreferencesStorage {
  const SecureSettingsPreferencesStorage({
    this.storage = const FlutterSecureStorage(),
  });

  static const _darkThemeKey = 'ledgerflow.preferences.dark_theme';
  static const _biometricsKey = 'ledgerflow.preferences.biometrics';

  final FlutterSecureStorage storage;

  @override
  Future<SettingsPreferences> read() async {
    final defaults = SettingsPreferences.defaults();

    return SettingsPreferences(
      darkThemeEnabled:
          _parseBool(await storage.read(key: _darkThemeKey)) ??
          defaults.darkThemeEnabled,
      biometricsEnabled:
          _parseBool(await storage.read(key: _biometricsKey)) ??
          defaults.biometricsEnabled,
    );
  }

  @override
  Future<void> save(SettingsPreferences preferences) async {
    await storage.write(
      key: _darkThemeKey,
      value: preferences.darkThemeEnabled.toString(),
    );
    await storage.write(
      key: _biometricsKey,
      value: preferences.biometricsEnabled.toString(),
    );
  }

  bool? _parseBool(String? value) {
    return switch (value) {
      'true' => true,
      'false' => false,
      _ => null,
    };
  }
}
