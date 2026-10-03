import 'package:new_app/app/safe_change_notifier.dart';
import 'package:new_app/core/services/preferences_service.dart';
import 'package:new_app/core/startup/startup.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/features/session/session_notifier.dart';

class SplashNotifier extends SafeChangeNotifier {
  SplashNotifier({
    required AuthRepository auth,
    required PreferencesService preferences,
    required SessionNotifier session,
    this.delay = const Duration(seconds: 2),
  }) : _auth = auth,
       _preferences = preferences,
       _session = session;

  final AuthRepository _auth;
  final PreferencesService _preferences;
  final SessionNotifier _session;

  /// Minimum time the branding stays visible.
  final Duration delay;

  /// Where the app should open; `null` while deciding.
  StartDestination? destination;

  Future<void> start() async {
    // Start the work immediately; the delay only sets a minimum duration.
    final decision = decideStart(auth: _auth, preferences: _preferences);
    await Future<void>.delayed(delay);
    final (result, user) = await decision;
    if (user != null) _session.signedIn(user);
    destination = result;
    notifyListeners();
  }
}
