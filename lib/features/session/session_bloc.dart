import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/data/models/user_model.dart';
import 'package:new_app/data/repositories/auth_repository.dart';

part 'session_event.dart';
part 'session_state.dart';

/// App-wide authentication state. The router listens to it, so signing in
/// or out navigates automatically.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc(this._auth) : super(const SessionState()) {
    on<SessionSignedIn>((event, emit) => emit(SessionState(event.user)));
    on<SessionLogoutRequested>((event, emit) async {
      await _auth.logout();
      emit(const SessionState());
    });
    on<SessionExpired>((event, emit) => emit(const SessionState()));
  }

  final AuthRepository _auth;
}
