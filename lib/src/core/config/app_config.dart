class AppConfig {
  const AppConfig._();

  static const appName = 'LedgerFlow';

  static const productionApiBaseUrl =
      'https://api-appledgerflow.lcamargo.dev.br';
  static const localApiBaseUrl = 'http://localhost:3020';
  static const androidEmulatorApiBaseUrl = 'http://10.0.2.2:3020';

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: productionApiBaseUrl,
  );
}
