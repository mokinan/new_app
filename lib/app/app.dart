import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../core/bindings/initial_binding.dart';
import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AppName',
      debugShowCheckedModeBanner: AppConfig.to.showDebugBanner,

      // ─── Theme ──────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: AppConfig.to.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ─── Routing ────────────────────────────────────────
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      initialBinding: InitialBinding(),

      // ─── Responsive Framework ────────────────────────────
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: const [
          Breakpoint(start: 0,    end: 599,   name: MOBILE),
          Breakpoint(start: 600,  end: 899,   name: TABLET),
          Breakpoint(start: 900,  end: 1199,  name: DESKTOP),
          Breakpoint(start: 1200, end: 1919,  name: '4K'),
          Breakpoint(start: 1920, end: double.infinity, name: 'TV'),
        ],
      ),

      // ─── Localization ────────────────────────────────────
      locale: Locale(AppConfig.to.locale),
      fallbackLocale: const Locale('en'),
    );
  }
}
