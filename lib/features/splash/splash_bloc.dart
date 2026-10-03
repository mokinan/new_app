import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/core/services/preferences_service.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/features/session/session_bloc.dart';

sealed class SplashEvent {
  const SplashEvent();
}

final class SplashStarted extends SplashEvent {
  const SplashStarted();
}

/// Emits where the app should open; `null` while deciding.
class SplashBloc extends Bloc<SplashEvent, StartDestination?> {
  SplashBloc({
    required AuthRepository auth,
    required PreferencesService preferences,
    required SessionBloc session,
    Duration delay = const Duration(seconds: 2),
  }) : super(null) {
    on<SplashStarted>((event, emit) async {
      // Start the work immediately; the delay only sets a minimum duration.
      final decision = decideStart(auth: auth, preferences: preferences);
      await Future<void>.delayed(delay);
      final (destination, user) = await decision;
      if (user != null) session.add(SessionSignedIn(user));
      emit(destination);
    });
  }
}
