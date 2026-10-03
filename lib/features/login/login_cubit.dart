import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/features/session/session_cubit.dart';

class LoginState extends Equatable {
  const LoginState({this.isLoading = false, this.error});

  final bool isLoading;
  final String? error;

  @override
  List<Object?> get props => [isLoading, error];
}

/// On success it only updates the session: the router redirects to home.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._auth, this._session) : super(const LoginState());

  final AuthRepository _auth;
  final SessionCubit _session;

  Future<void> submit({required String email, required String password}) async {
    if (state.isLoading) return;
    emit(const LoginState(isLoading: true));
    try {
      final user = await _auth.login(email: email, password: password);
      _session.signedIn(user);
      if (!isClosed) emit(const LoginState());
    } on ApiException catch (e) {
      if (!isClosed) emit(LoginState(error: e.message));
    }
  }
}
