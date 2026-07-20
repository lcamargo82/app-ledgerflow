class SettingsPreferences {
  const SettingsPreferences({
    required this.darkThemeEnabled,
    required this.biometricsEnabled,
  });

  final bool darkThemeEnabled;
  final bool biometricsEnabled;

  factory SettingsPreferences.defaults() {
    return const SettingsPreferences(
      darkThemeEnabled: true,
      biometricsEnabled: false,
    );
  }

  SettingsPreferences copyWith({
    bool? darkThemeEnabled,
    bool? biometricsEnabled,
  }) {
    return SettingsPreferences(
      darkThemeEnabled: darkThemeEnabled ?? this.darkThemeEnabled,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    );
  }
}
