import 'package:get/get.dart';
import 'package:new_app/app/routes/app_routes.dart';
import 'package:new_app/data/models/user_model.dart';
import 'package:new_app/data/repositories/auth_repository.dart';

/// App-wide authentication state: who is signed in.
/// Registered once as a permanent singleton (see `registerDependencies`).
class SessionController extends GetxController {
  SessionController(this._auth);

  static SessionController get to => Get.find();

  final AuthRepository _auth;

  final _user = Rxn<UserModel>();

  UserModel? get user => _user.value;
  bool get isLoggedIn => _user.value != null;

  void signedIn(UserModel user) => _user.value = user;

  Future<void> logout() async {
    await _auth.logout();
    _user.value = null;
    await Get.offAllNamed<void>(AppRoutes.login);
  }

  /// Called by `AuthInterceptor` when the refresh token is rejected.
  void onSessionExpired() {
    _user.value = null;
    Get.offAllNamed<void>(AppRoutes.login);
  }
}
