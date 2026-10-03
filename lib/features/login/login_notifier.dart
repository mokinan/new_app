import 'package:new_app/app/safe_change_notifier.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/features/session/session_notifier.dart';

/// On success it only updates the session: the router redirects to home.
class LoginNotifier extends SafeChangeNotifier {
  LoginNotifier(this._auth, this._session);

  final AuthRepository _auth;
  final SessionNotifier _session;

  bool isLoading = false;
  String? error;

  Future<void> submit({required String email, required String password}) async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final user = await _auth.login(email: email, password: password);
      _session.signedIn(user);
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
