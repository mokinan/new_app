import 'package:flutter/widgets.dart';
import 'package:new_app/core/widgets/onboarding_widgets.dart';

/// Pure branding; `SplashController` (created by `SplashBinding`) decides
/// where to go next.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) => const SplashBranding();
}
