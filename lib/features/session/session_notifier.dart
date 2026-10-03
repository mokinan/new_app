import 'package:new_app/app/safe_change_notifier.dart';
import 'package:new_app/data/models/user_model.dart';
import 'package:new_app/data/repositories/auth_repository.dart';

/// App-wide authentication state. It is the router's `refreshListenable`,
/// so signing in or out navigates automatically.
class SessionNotifier extends SafeChangeNotifier {
  SessionNotifier(this._auth);

  final AuthRepository _auth;

  UserModel? _user;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  void signedIn(UserModel user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    _user = null;
    notifyListeners();
  }

  /// Called by `AuthInterceptor` when the refresh token is rejected.
  void expired() {
    _user = null;
    notifyListeners();
  }
}
