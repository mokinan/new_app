part of 'session_bloc.dart';

class SessionState extends Equatable {
  const SessionState([this.user]);

  final UserModel? user;

  bool get isLoggedIn => user != null;

  @override
  List<Object?> get props => [user?.id, user?.email];
}
