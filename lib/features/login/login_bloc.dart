import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/features/session/session_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

/// On success it only updates the session: the router redirects to home.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._auth, this._session) : super(const LoginState()) {
    // `droppable`: taps while a request is in flight are ignored, so the
    // form can never be submitted twice.
    on<LoginSubmitted>(_onSubmitted, transformer: droppable());
  }

  final AuthRepository _auth;
  final SessionBloc _session;

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(const LoginState(isLoading: true));
    try {
      final user = await _auth.login(email: event.email, password: event.password);
      _session.add(SessionSignedIn(user));
      emit(const LoginState());
    } on ApiException catch (e) {
      emit(LoginState(error: e.message));
    }
  }
}
