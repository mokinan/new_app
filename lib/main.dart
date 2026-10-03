import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_app/app/app.dart';
import 'package:new_app/app/dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await registerDependencies();
  runApp(const App());
}
