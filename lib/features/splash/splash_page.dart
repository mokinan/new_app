import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/app/notifier_listener.dart';
import 'package:new_app/app/router.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/core/widgets/onboarding_widgets.dart';
import 'package:new_app/features/splash/splash_notifier.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SplashNotifier(
        auth: context.read(),
        preferences: context.read(),
        session: context.read(),
        delay: context.read<AppConfig>().splashDelay,
      )..start(),
      child: NotifierListener<SplashNotifier>(
        listener: (context, splash) => context.go(switch (splash.destination) {
          StartDestination.home => AppRoutes.home,
          StartDestination.login => AppRoutes.login,
          StartDestination.welcome || null => AppRoutes.welcome,
        }),
        child: const SplashBranding(),
      ),
    );
  }
}
