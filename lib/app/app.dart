import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/app/dependencies.dart';
import 'package:new_app/app/router.dart';
import 'package:new_app/core/theme/app_theme.dart';
import 'package:new_app/features/session/session_bloc.dart';
import 'package:new_app/features/settings/settings_bloc.dart';

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
  late final SessionBloc _session = SessionBloc(_deps.authRepository);
  late final SettingsBloc _settings = SettingsBloc(_deps.preferences);
  late final GoRouter _router = createRouter(_session, initialLocation: widget.initialLocation);

  @override
  void initState() {
    super.initState();
    _deps.onSessionExpired = () => _session.add(const SessionExpired());
  }

  @override
  void dispose() {
    _router.dispose();
    _session.close();
    _settings.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _deps.config),
        RepositoryProvider.value(value: _deps.preferences),
        RepositoryProvider.value(value: _deps.authRepository),
        RepositoryProvider.value(value: _deps.onboardingRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _session),
          BlocProvider.value(value: _settings),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settings) => MaterialApp.router(
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
      ),
    );
  }
}
