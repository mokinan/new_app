import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppEnvironment { development, staging, production }

class AppConfig extends GetxController {
  static AppConfig get to => Get.find<AppConfig>();

  // ─── Environment ──────────────────────────────────────────
  final AppEnvironment environment;

  AppConfig({this.environment = AppEnvironment.development});

  // ─── App Info ─────────────────────────────────────────────
  String appName        = 'AppName';
  String appVersion     = '1.0.0';
  String buildNumber    = '1';
  String packageName    = '';

  // ─── API ──────────────────────────────────────────────────
  String get baseUrl {
    switch (environment) {
      case AppEnvironment.production:
        return 'https://api.yourapp.com/v1';
      case AppEnvironment.staging:
        return 'https://staging-api.yourapp.com/v1';
      case AppEnvironment.development:
        return 'https://dev-api.yourapp.com/v1';
    }
  }

  int get connectTimeout => 30000;
  int get receiveTimeout => 30000;

  // ─── Feature Flags ────────────────────────────────────────
  bool get enableAnalytics  => environment == AppEnvironment.production;
  bool get enableCrashReport => environment != AppEnvironment.development;
  bool get showDebugBanner   => environment == AppEnvironment.development;

  // ─── User Preferences (reactive) ──────────────────────────
  final _isDarkMode     = false.obs;
  final _locale         = 'en'.obs;
  final _isOnboarded    = false.obs;

  bool   get isDarkMode    => _isDarkMode.value;
  String get locale        => _locale.value;
  bool   get isOnboarded   => _isOnboarded.value;

  // ─── Lifecycle ────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    _loadPackageInfo();
  }

  // ─── Setters ──────────────────────────────────────────────
  Future<void> setDarkMode(bool value) async {
    _isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    await _prefs?.setBool('isDarkMode', value);
  }

  Future<void> setLocale(String langCode) async {
    _locale.value = langCode;
    Get.updateLocale(Locale(langCode));
    await _prefs?.setString('locale', langCode);
  }

  Future<void> setOnboarded(bool value) async {
    _isOnboarded.value = value;
    await _prefs?.setBool('isOnboarded', value);
  }

  // ─── Private ──────────────────────────────────────────────
  SharedPreferences? _prefs;

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode.value  = _prefs?.getBool('isDarkMode')   ?? false;
    _locale.value      = _prefs?.getString('locale')     ?? 'en';
    _isOnboarded.value = _prefs?.getBool('isOnboarded')  ?? false;
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info  = await PackageInfo.fromPlatform();
      appName     = info.appName;
      appVersion  = info.version;
      buildNumber = info.buildNumber;
      packageName = info.packageName;
    } catch (_) {}
  }

  // ─── Debug ────────────────────────────────────────────────
  @override
  String toString() =>
      'AppConfig(env: $environment, version: $appVersion, baseUrl: $baseUrl)';
}
