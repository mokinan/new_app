import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/core/services/preferences_service.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/features/session/session_cubit.dart';

/// Emits where the app should open; `null` while deciding.
class SplashCubit extends Cubit<StartDestination?> {
  SplashCubit({
    required AuthRepository auth,
    required PreferencesService preferences,
    required SessionCubit session,
    this.delay = const Duration(seconds: 2),
  }) : _auth = auth,
       _preferences = preferences,
       _session = session,
       super(null);

  final AuthRepository _auth;
  final PreferencesService _preferences;
  final SessionCubit _session;

  /// Minimum time the branding stays visible.
  final Duration delay;

  Future<void> start() async {
    // Start the work immediately; the delay only sets a minimum duration.
    final decision = decideStart(auth: _auth, preferences: _preferences);
    await Future<void>.delayed(delay);
    final (destination, user) = await decision;
    if (user != null) _session.signedIn(user);
    if (!isClosed) emit(destination);
  }
}
