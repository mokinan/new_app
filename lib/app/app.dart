import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:new_app/app/routes/app_pages.dart';
import 'package:new_app/app/routes/app_routes.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/core/theme/app_theme.dart';
import 'package:new_app/features/settings/settings_controller.dart';

class App extends StatelessWidget {
  const App({this.initialRoute = AppRoutes.splash, super.key});

  /// Override for deep links (e.g. a notification opening `/home`).
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.to;
    return GetMaterialApp(
      title: 'AppName',
      debugShowCheckedModeBanner: Get.find<AppConfig>().showDebugBanner,

      // ─── Theme ──────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,

      // ─── Routing ────────────────────────────────────────
      initialRoute: initialRoute,
      getPages: AppPages.pages,

      // ─── Localization ───────────────────────────────────
      locale: settings.locale.value,
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
