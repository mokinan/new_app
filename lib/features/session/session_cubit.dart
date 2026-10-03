import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/data/models/user_model.dart';
import 'package:new_app/data/repositories/auth_repository.dart';

class SessionState extends Equatable {
  const SessionState([this.user]);

  final UserModel? user;

  bool get isLoggedIn => user != null;

  @override
  List<Object?> get props => [user?.id, user?.email];
}

/// App-wide authentication state. The router listens to it, so signing in
/// or out navigates automatically.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._auth) : super(const SessionState());

  final AuthRepository _auth;

  void signedIn(UserModel user) => emit(SessionState(user));

  Future<void> logout() async {
    await _auth.logout();
    emit(const SessionState());
  }

  /// Called by `AuthInterceptor` when the refresh token is rejected.
  void expired() => emit(const SessionState());
}
