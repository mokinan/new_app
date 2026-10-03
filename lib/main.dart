import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Init storage first (SharedPreferences needs async init)
  await StorageService.instance.init();

  // Register singletons before App.build() reads them
  Get.put(AppConfig(environment: AppEnvironment.development), permanent: true);
  Get.put(AuthService(), permanent: true);

  runApp(const App());
}
