import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/app/router.dart';
import 'package:new_app/core/config/app_config.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/core/widgets/onboarding_widgets.dart';
import 'package:new_app/features/splash/splash_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc(
        auth: context.read(),
        preferences: context.read(),
        session: context.read(),
        delay: context.read<AppConfig>().splashDelay,
      )..add(const SplashStarted()),
      child: BlocListener<SplashBloc, StartDestination?>(
        listener: (context, destination) => context.go(switch (destination) {
          StartDestination.home => AppRoutes.home,
          StartDestination.login => AppRoutes.login,
          StartDestination.welcome || null => AppRoutes.welcome,
        }),
        child: const SplashBranding(),
      ),
    );
  }
}
