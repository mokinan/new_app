import 'package:new_app/core/services/preferences_service.dart';
import 'package:new_app/data/models/user_model.dart';
import 'package:new_app/data/repositories/auth_repository.dart';

enum StartDestination { home, login, welcome }

/// Where the app should open — the same rule in every branch:
/// a restorable session → home; onboarded → login; otherwise → welcome.
///
/// Storage errors fall back to login rather than trapping the user on the
/// splash screen.
Future<(StartDestination, UserModel?)> decideStart({
  required AuthRepository auth,
  required PreferencesService preferences,
  Duration timeout = const Duration(seconds: 4),
}) async {
  try {
    final user = await auth.restoreSession().timeout(timeout);
    if (user != null) return (StartDestination.home, user);
    return (preferences.isOnboarded ? StartDestination.login : StartDestination.welcome, null);
  } on Object {
    return (StartDestination.login, null);
  }
}
