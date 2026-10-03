/// Where the app talks to.
///
/// [mock] runs entirely on the device with a fake backend, so the template
/// works out of the box and integration tests need no server.
enum AppEnvironment { mock, development, staging, production }

/// Build-time configuration. Immutable and free of any state-management
/// framework, so every branch of this template shares it unchanged.
///
/// Pick the environment at build time:
/// `flutter run --dart-define=ENV=staging`
class AppConfig {
  const AppConfig({this.environment = AppEnvironment.mock});

  /// Reads `--dart-define=ENV=...`; defaults to [AppEnvironment.mock].
  factory AppConfig.fromEnvironment() {
    const name = String.fromEnvironment('ENV', defaultValue: 'mock');
    return AppConfig(
      environment: AppEnvironment.values.firstWhere((e) => e.name == name, orElse: () => AppEnvironment.mock),
    );
  }

  final AppEnvironment environment;

  // ─── API ──────────────────────────────────────────────────
  String get baseUrl => switch (environment) {
    AppEnvironment.production => 'https://api.yourapp.com/v1',
    AppEnvironment.staging => 'https://staging-api.yourapp.com/v1',
    AppEnvironment.development => 'https://dev-api.yourapp.com/v1',
    AppEnvironment.mock => 'https://mock.local/v1',
  };

  Duration get connectTimeout => const Duration(seconds: 30);
  Duration get receiveTimeout => const Duration(seconds: 30);

  // ─── Feature flags ────────────────────────────────────────
  bool get useMockBackend => environment == AppEnvironment.mock;
  bool get enableAnalytics => environment == AppEnvironment.production;
  bool get enableCrashReport => environment == AppEnvironment.staging || environment == AppEnvironment.production;
  bool get showDebugBanner => environment != AppEnvironment.production;
  bool get logNetwork => environment != AppEnvironment.production;

  @override
  String toString() => 'AppConfig(env: ${environment.name}, baseUrl: $baseUrl)';
}
