import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/app/providers.dart';
import 'package:new_app/data/models/user_model.dart';

/// App-wide authentication state: the signed-in user, or `null`.
/// The router listens to it, so signing in or out navigates automatically.
class SessionNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => null;

  bool get isLoggedIn => state != null;

  void signedIn(UserModel user) => state = user;

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = null;
  }

  /// Called by `AuthInterceptor` when the refresh token is rejected.
  void expired() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, UserModel?>(SessionNotifier.new);
