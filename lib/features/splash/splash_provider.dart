import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/app/providers.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/features/session/session_notifier.dart';

/// Where the app should open. A one-shot async computation, so a plain
/// `FutureProvider` is enough — no notifier needed.
final startDestinationProvider = FutureProvider.autoDispose<StartDestination>((ref) async {
  // Start the work immediately; the delay only sets a minimum duration.
  final decision = decideStart(
    auth: ref.read(authRepositoryProvider),
    preferences: ref.read(preferencesServiceProvider),
  );
  await Future<void>.delayed(ref.read(appConfigProvider).splashDelay);
  final (destination, user) = await decision;
  if (user != null) ref.read(sessionProvider.notifier).signedIn(user);
  return destination;
});
