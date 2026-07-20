import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerflow/src/features/settings/domain/settings_preferences.dart';

void main() {
  test('uses dark theme enabled and biometrics disabled by default', () {
    final preferences = SettingsPreferences.defaults();

    expect(preferences.darkThemeEnabled, isTrue);
    expect(preferences.biometricsEnabled, isFalse);
  });

  test('copies local preference values independently', () {
    final preferences = SettingsPreferences.defaults().copyWith(
      biometricsEnabled: true,
    );

    expect(preferences.darkThemeEnabled, isTrue);
    expect(preferences.biometricsEnabled, isTrue);
  });
}
