import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/app/router.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/core/widgets/onboarding_widgets.dart';
import 'package:new_app/features/splash/splash_provider.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `ref.listen` for the side effect (navigation); nothing to rebuild.
    ref.listen(startDestinationProvider, (_, next) {
      final destination = next.value;
      if (destination == null) return;
      context.go(switch (destination) {
        StartDestination.home => AppRoutes.home,
        StartDestination.login => AppRoutes.login,
        StartDestination.welcome => AppRoutes.welcome,
      });
    });
    return const SplashBranding();
  }
}
