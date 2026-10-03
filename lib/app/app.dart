import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/app/dependencies.dart';
import 'package:new_app/app/router.dart';
import 'package:new_app/core/theme/app_theme.dart';
import 'package:new_app/features/session/session_notifier.dart';
import 'package:new_app/features/settings/settings_notifier.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({required this.dependencies, this.initialLocation = AppRoutes.splash, super.key});

  final AppDependencies dependencies;

  /// Override for deep links (e.g. a notification opening `/home`).
  final String initialLocation;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppDependencies _deps = widget.dependencies;
  late final SessionNotifier _session = SessionNotifier(_deps.authRepository);
  late final SettingsNotifier _settings = SettingsNotifier(_deps.preferences);
  late final GoRouter _router = createRouter(_session, initialLocation: widget.initialLocation);

  @override
  void initState() {
    super.initState();
    _deps.onSessionExpired = _session.expired;
  }

  @override
  void dispose() {
    _router.dispose();
    _session.dispose();
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Plain objects: `Provider.value`. Notifiers: `ChangeNotifierProvider.value`
        // (owned and disposed by this State, not by the provider).
        Provider.value(value: _deps.config),
        Provider.value(value: _deps.preferences),
        Provider.value(value: _deps.authRepository),
        Provider.value(value: _deps.onboardingRepository),
        ChangeNotifierProvider.value(value: _session),
        ChangeNotifierProvider.value(value: _settings),
      ],
      child: Consumer<SettingsNotifier>(
        builder: (context, settings, _) => MaterialApp.router(
          title: 'AppName',
          debugShowCheckedModeBanner: _deps.config.showDebugBanner,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: _router,
        ),
      ),
    );
  }
}
